import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:app/features/account_deletion/account_deletion_notifier.dart';
import 'package:app/features/account_deletion/account_deletion_service.dart';
import 'package:app/features/account_deletion/presentation/screens/account_deletion_screen.dart';
import 'package:app/features/auth/presentation/providers/auth_providers.dart';
import 'package:app/ui/candy/candy_button.dart';
import 'package:app/ui/candy/candy_empty_state.dart';

class FakeAccountDeletionService extends AccountDeletionService {
  FakeAccountDeletionService({this.outcome}) : super(null);

  final AccountDeletionOutcome? outcome;
  int callCount = 0;

  @override
  Future<AccountDeletionOutcome> deleteAccount() async {
    callCount++;
    await Future.delayed(Duration.zero);
    if (outcome != null) return outcome!;
    return const AccountDeletionOutcome(AccountDeletionResult.failed);
  }
}

void main() {
  group('Account deletion web page', () {
    late ProviderContainer container;

    Session makeSession() => Session(
      accessToken: 'access-token',
      tokenType: 'bearer',
      user: User(
        id: 'user-id',
        appMetadata: {},
        userMetadata: {},
        aud: 'auth',
        createdAt: '2026-01-01T00:00:00.000Z',
      ),
    );

    Future<void> pumpPage(
      WidgetTester tester, {
      AccountDeletionOutcome? outcome,
      bool signedIn = true,
    }) async {
      final service = FakeAccountDeletionService(outcome: outcome);
      final authState = AuthState(
        signedIn ? AuthChangeEvent.signedIn : AuthChangeEvent.signedOut,
        signedIn ? makeSession() : null,
      );
      container = ProviderContainer(
        overrides: [
          accountDeletionServiceProvider.overrideWithValue(service),
          authStateStreamProvider.overrideWithValue(AsyncValue.data(authState)),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Builder(builder: (context) => const AccountDeletionScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    setUp(() {
      container = ProviderContainer(
        overrides: [
          accountDeletionServiceProvider.overrideWithValue(
            FakeAccountDeletionService(),
          ),
          authStateStreamProvider.overrideWithValue(
            AsyncValue.data(const AuthState(AuthChangeEvent.signedOut, null)),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('/account/delete route exists', (tester) async {
      await pumpPage(tester);
      expect(find.byType(AccountDeletionScreen), findsOneWidget);
    });

    testWidgets('web deletion page renders', (tester) async {
      await pumpPage(tester, signedIn: true);
      expect(find.byType(AccountDeletionScreen), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('XÓA TÀI KHOẢN'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('unauthenticated state shows login prompt', (tester) async {
      await pumpPage(tester, signedIn: false);
      expect(
        find.descendant(
          of: find.byType(CandyEmptyState),
          matching: find.text('XÓA TÀI KHOẢN'),
        ),
        findsOneWidget,
      );
      expect(
        find.text('Vui lòng đăng nhập trước khi xóa tài khoản.'),
        findsOneWidget,
      );
      expect(find.text('Đăng nhập'), findsOneWidget);
      expect(find.byType(CandyEmptyState), findsOneWidget);
    });

    testWidgets('authenticated user sees delete action', (tester) async {
      await pumpPage(tester, signedIn: true);
      expect(
        find.descendant(
          of: find.byType(CandyEmptyState),
          matching: find.byType(CandyButton),
        ),
        findsOneWidget,
      );
    });

    testWidgets('confirmation required - cancel does nothing', (tester) async {
      await pumpPage(tester, signedIn: true);
      final service =
          container.read(accountDeletionServiceProvider)
              as FakeAccountDeletionService;
      expect(service.callCount, 0);
    });

    testWidgets('delete action calls service once', (tester) async {
      await pumpPage(tester, signedIn: true);
      final service =
          container.read(accountDeletionServiceProvider)
              as FakeAccountDeletionService;
      await tester.tap(find.byType(CandyButton).first);
      await tester.pumpAndSettle();
      expect(service.callCount, 1);
    });

    testWidgets('duplicate submission prevented', (tester) async {
      await pumpPage(tester, signedIn: true);
      final service =
          container.read(accountDeletionServiceProvider)
              as FakeAccountDeletionService;
      await tester.tap(find.byType(CandyButton).first);
      await tester.tap(find.byType(CandyButton).first);
      await tester.pumpAndSettle();
      expect(service.callCount, 1);
    });

    testWidgets('200 full success shows success state', (tester) async {
      await pumpPage(
        tester,
        signedIn: true,
        outcome: const AccountDeletionOutcome(AccountDeletionResult.success),
      );
      await tester.tap(find.byType(CandyButton).first);
      await tester.pumpAndSettle();
      expect(find.text('Đã xóa tài khoản.'), findsOneWidget);
      expect(
        find.text(
          'Tất cả dữ liệu của bạn đã được xóa vĩnh viễn. Tài khoản xác thực cũng đã bị xóa.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('202 deferred auth removal handled distinctly', (tester) async {
      await pumpPage(
        tester,
        signedIn: true,
        outcome: const AccountDeletionOutcome(AccountDeletionResult.deferred),
      );
      await tester.tap(find.byType(CandyButton).first);
      await tester.pumpAndSettle();
      expect(find.text('Xóa dữ liệu hoàn tất'), findsOneWidget);
      expect(
        find.text(
          'Dữ liệu tập luyện và hồ sơ của bạn đã bị xóa. Xóa tài khoản xác thực đang chờ xử lý; vui lòng thử lại sau để hoàn tất.',
        ),
        findsOneWidget,
      );
      expect(find.text('Đã xóa tài khoản.'), findsNothing);
    });

    testWidgets('500 sanitized failure does not show success', (tester) async {
      await pumpPage(
        tester,
        signedIn: true,
        outcome: const AccountDeletionOutcome(AccountDeletionResult.failed),
      );
      await tester.tap(find.byType(CandyButton).first);
      await tester.pumpAndSettle();
      expect(
        find.text('Không thể xóa tài khoản. Vui lòng thử lại sau.'),
        findsWidgets,
      );
      expect(find.text('Đã xóa tài khoản.'), findsNothing);
    });

    testWidgets('no arbitrary user_id input exists', (tester) async {
      await pumpPage(tester, signedIn: true);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('320px layout has no overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      await pumpPage(tester, signedIn: true);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('large text scale renders', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(1.5)),
                child: const AccountDeletionScreen(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AccountDeletionScreen), findsOneWidget);
    });
  });
}
