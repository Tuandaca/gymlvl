import 'dart:async';

/// The identity currently authenticated by the host application.
///
/// An owner ID passed to a store method is never proof of authentication. The
/// production adapter must derive this value from Supabase Auth, not a caller.
abstract interface class OfflineAuthenticatedSession {
  String? get authenticatedOwnerId;
  int get generation;
  Stream<int> get changes;

  /// Ends the authenticated session. Never deletes queued offline work.
  void logout();
}

/// Deterministic local/test session. No production code constructs this type.
final class SyntheticOfflineAuthSession implements OfflineAuthenticatedSession {
  String? _ownerId;
  int _generation = 0;
  final StreamController<int> _changes = StreamController<int>.broadcast(
    sync: true,
  );

  SyntheticOfflineAuthSession([this._ownerId]);

  @override
  String? get authenticatedOwnerId => _ownerId;

  @override
  int get generation => _generation;

  @override
  Stream<int> get changes => _changes.stream;

  void changeOwner(String? ownerId) {
    if (ownerId == _ownerId) return;
    _ownerId = ownerId;
    _generation++;
    _changes.add(_generation);
  }

  /// Ends the authenticated session without touching queued rows.
  ///
  /// Logout clears the authenticated owner and bumps the generation, so no
  /// in-flight or subsequent sync claim can proceed for the prior owner. It is
  /// deliberately *not* a discard: queued intents, projections, and their keys
  /// stay exactly as they were and remain recoverable by the same owner after
  /// re-authentication.
  @override
  void logout() => changeOwner(null);

  Future<void> close() => _changes.close();
}
