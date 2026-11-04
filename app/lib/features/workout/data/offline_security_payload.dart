/// Production gate for offline payload protection.
///
/// It stays `false` until production key storage is wired to a real
/// Supabase-Auth-derived owner lifecycle and the D-041 evidence gate is met.
/// The implementation lives in `offline_payload_cipher.dart`
/// (`OfflinePayloadCipher`) and `offline_secure_key_store.dart`
/// (`PlatformSecureOfflinePayloadKeyStore`).
///
/// Key policy, in force for any future wiring:
/// - Keys come from platform-backed secure storage, never from SQLite, source,
///   environment files, or shared preferences.
/// - Every envelope is bound to its owner, operation, workout, contract
///   version, and mutation kind through AES-GCM associated data.
/// - A missing key or a failed authentication fails closed: no plaintext
///   fallback, no row deletion, no acknowledgement.
const bool productionOfflinePayloadProtectionEnabled = false;
