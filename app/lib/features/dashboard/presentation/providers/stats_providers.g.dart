// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DashboardStatsController)
final dashboardStatsControllerProvider = DashboardStatsControllerProvider._();

final class DashboardStatsControllerProvider
    extends $AsyncNotifierProvider<DashboardStatsController, DashboardStats?> {
  DashboardStatsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardStatsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardStatsControllerHash();

  @$internal
  @override
  DashboardStatsController create() => DashboardStatsController();
}

String _$dashboardStatsControllerHash() =>
    r'71a0813eab58287bc4c107dbb9e227626a974311';

abstract class _$DashboardStatsController
    extends $AsyncNotifier<DashboardStats?> {
  FutureOr<DashboardStats?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DashboardStats?>, DashboardStats?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DashboardStats?>, DashboardStats?>,
              AsyncValue<DashboardStats?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
