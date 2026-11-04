import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'offline_payload_cipher.dart';

/// One AES-256 key for one owner and key version.
///
/// The bytes are copied on construction and never logged or serialized into a
/// payload row.
final class OfflinePayloadKey {
  static const int length = 32;

  final int version;
  final Uint8List bytes;

  OfflinePayloadKey({required this.version, required Uint8List bytes})
    : bytes = Uint8List.fromList(bytes) {
    if (version < 1) {
      throw ArgumentError.value(version, 'version');
    }
    if (this.bytes.length != length) {
      throw ArgumentError.value(
        this.bytes.length,
        'bytes',
        'Offline payload keys must be $length bytes',
      );
    }
  }
}

/// Narrow key access. There is deliberately no enumeration or bulk delete.
abstract interface class OfflinePayloadKeyStore {
  Future<OfflinePayloadKey?> readKey(String ownerId, int keyVersion);

  Future<OfflinePayloadKey> createKey(String ownerId, int keyVersion);
}

/// Deterministic, process-local key store for tests only.
///
/// [seededKeys] is keyed by [keyId] so a test can pin exact key material for a
/// given owner and version. Nothing here touches a device keystore.
final class InMemoryOfflinePayloadKeyStore implements OfflinePayloadKeyStore {
  final Map<String, Uint8List> _keys = {};
  final Random _random;
  int createCount = 0;
  int readCount = 0;

  InMemoryOfflinePayloadKeyStore({
    Map<String, Uint8List>? seededKeys,
    Random? random,
  }) : _random = random ?? Random(0) {
    seededKeys?.forEach((id, bytes) {
      _keys[id] = Uint8List.fromList(bytes);
    });
  }

  /// Stable identifier for one owner/version pair, used to seed exact keys.
  static String keyId(String ownerId, int keyVersion) =>
      '$ownerId:v$keyVersion';

  @override
  Future<OfflinePayloadKey?> readKey(String ownerId, int keyVersion) async {
    readCount++;
    final bytes = _keys[keyId(ownerId, keyVersion)];
    if (bytes == null) return null;
    return OfflinePayloadKey(version: keyVersion, bytes: bytes);
  }

  /// Creates the key when absent and returns the existing key otherwise.
  @override
  Future<OfflinePayloadKey> createKey(String ownerId, int keyVersion) async {
    createCount++;
    final id = keyId(ownerId, keyVersion);
    var bytes = _keys[id];
    if (bytes == null) {
      bytes = Uint8List(OfflinePayloadKey.length);
      for (var index = 0; index < bytes.length; index++) {
        bytes[index] = _random.nextInt(256);
      }
      _keys[id] = bytes;
    }
    return OfflinePayloadKey(version: keyVersion, bytes: bytes);
  }

  /// Owner-scoped removal used to prove that a missing key fails closed.
  ///
  /// Only an explicit owner action may call this in production; it must never be
  /// reachable from logout, discard, or any cleanup path.
  Future<bool> deleteKeyForOwner(String ownerId, int keyVersion) async =>
      _keys.remove(keyId(ownerId, keyVersion)) != null;
}

/// Platform-backed key storage through the OS keystore.
///
/// The stored value is the base64 of the 32 raw key bytes; the key name carries
/// the owner and version. No key material is written to SQLite, source control,
/// environment files, or shared preferences. Only the owner's explicit action
/// may call [deleteKeyForOwner].
final class PlatformSecureOfflinePayloadKeyStore
    implements OfflinePayloadKeyStore {
  static const String keyPrefix = 'gymlvl.offline.payload.key';

  final FlutterSecureStorage _storage;
  final Random _random;

  PlatformSecureOfflinePayloadKeyStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
    Random? random,
  }) : _storage = storage,
       _random = random ?? Random.secure();

  static String storageKeyName(String ownerId, int keyVersion) =>
      '$keyPrefix.$ownerId.v$keyVersion';

  @override
  Future<OfflinePayloadKey?> readKey(String ownerId, int keyVersion) async {
    final name = storageKeyName(ownerId, keyVersion);
    final encoded = await _storage.read(key: name);
    if (encoded == null) return null;
    final Uint8List bytes;
    try {
      bytes = base64Decode(encoded);
    } on FormatException {
      throw const OfflinePayloadKeyUnavailableException();
    }
    if (bytes.length != OfflinePayloadKey.length) {
      throw const OfflinePayloadKeyUnavailableException();
    }
    return OfflinePayloadKey(version: keyVersion, bytes: bytes);
  }

  @override
  Future<OfflinePayloadKey> createKey(String ownerId, int keyVersion) async {
    final existing = await readKey(ownerId, keyVersion);
    if (existing != null) return existing;
    final bytes = Uint8List(OfflinePayloadKey.length);
    for (var index = 0; index < bytes.length; index++) {
      bytes[index] = _random.nextInt(256);
    }
    final key = OfflinePayloadKey(version: keyVersion, bytes: bytes);
    await _storage.write(
      key: storageKeyName(ownerId, keyVersion),
      value: base64Encode(bytes),
    );
    return key;
  }

  /// Owner-scoped removal of one key version. Not exposed to logout or discard.
  Future<void> deleteKeyForOwner(String ownerId, int keyVersion) =>
      _storage.delete(key: storageKeyName(ownerId, keyVersion));
}
