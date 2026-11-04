import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../domain/workout_write_identity.dart';
import 'offline_secure_key_store.dart';
import 'offline_security_payload.dart';

/// AES-256-GCM payload envelope stored in place of a plaintext payload.
///
/// One row stores exactly one envelope: [cipherVersion], [keyVersion], the
/// 96-bit [nonce], and [ciphertextWithTag] which is the ciphertext followed by
/// the 128-bit GCM authentication tag. The plaintext never leaves memory.
final class OfflinePayloadEnvelope {
  /// Version of the envelope format, not of the key.
  static const int currentCipherVersion = 1;
  static const int nonceLength = 12;
  static const int tagLength = 16;

  final int cipherVersion;
  final int keyVersion;
  final Uint8List nonce;
  final Uint8List ciphertextWithTag;

  OfflinePayloadEnvelope({
    required this.cipherVersion,
    required this.keyVersion,
    required Uint8List nonce,
    required Uint8List ciphertextWithTag,
  }) : nonce = Uint8List.fromList(nonce),
       ciphertextWithTag = Uint8List.fromList(ciphertextWithTag) {
    if (cipherVersion < 1 || keyVersion < 1) {
      throw const OfflinePayloadFormatException(
        'Envelope format and key versions must be positive',
      );
    }
    if (this.nonce.length != nonceLength) {
      throw const OfflinePayloadFormatException(
        'Envelope nonce length invalid',
      );
    }
    if (this.ciphertextWithTag.length <= tagLength) {
      throw const OfflinePayloadFormatException(
        'Envelope ciphertext is shorter than its tag',
      );
    }
  }

  /// Rebuilds a stored envelope from its four columns.
  ///
  /// Returns `null` for a legacy plaintext row. Throws when the columns are
  /// partially present or when plaintext and ciphertext coexist in one row, so
  /// the "never both" invariant is enforced at the read boundary.
  static OfflinePayloadEnvelope? fromColumns({
    required int? cipherVersion,
    required int? keyVersion,
    required Uint8List? nonce,
    required Uint8List? ciphertextWithTag,
    required bool hasPlaintext,
  }) {
    final present = [
      cipherVersion,
      keyVersion,
      nonce,
      ciphertextWithTag,
    ].where((value) => value != null).length;
    if (present == 0) {
      if (hasPlaintext) return null;
      throw const OfflinePayloadFormatException(
        'Row has neither a plaintext payload nor an envelope',
      );
    }
    if (present != 4) {
      throw const OfflinePayloadFormatException(
        'Envelope columns are only partially populated',
      );
    }
    if (hasPlaintext) {
      throw const OfflinePayloadFormatException(
        'Row holds both a plaintext payload and a ciphertext',
      );
    }
    return OfflinePayloadEnvelope(
      cipherVersion: cipherVersion!,
      keyVersion: keyVersion!,
      nonce: nonce!,
      ciphertextWithTag: ciphertextWithTag!,
    );
  }

  @override
  String toString() =>
      'OfflinePayloadEnvelope(cipherVersion: $cipherVersion, '
      'keyVersion: $keyVersion, nonceLength: ${nonce.length}, '
      'ciphertextLength: ${ciphertextWithTag.length})';
}

/// Authenticated metadata bound to one envelope.
///
/// The associated data is a length-prefixed concatenation of every field, so an
/// envelope cannot be moved to another owner, operation, or workout, and no two
/// distinct bindings can encode to the same bytes.
final class OfflineWriteBinding {
  static const int setCreateContractVersion = 1;
  static const String setCreateMutationKind = 'set_create_v1';
  static const String _domain = 'gymlvl.offline.payload.v1';

  final String ownerId;
  final String workoutId;
  final String operationId;
  final int contractVersion;
  final String mutationKind;

  OfflineWriteBinding({
    required this.ownerId,
    required this.workoutId,
    required this.operationId,
    required this.contractVersion,
    required this.mutationKind,
  }) {
    _requireText(ownerId, 'ownerId');
    _requireText(workoutId, 'workoutId');
    _requireText(operationId, 'operationId');
    _requireText(mutationKind, 'mutationKind');
    if (contractVersion < 1) {
      throw ArgumentError.value(contractVersion, 'contractVersion');
    }
  }

  factory OfflineWriteBinding.setCreate(WorkoutWriteIdentity identity) =>
      OfflineWriteBinding(
        ownerId: identity.ownerId,
        workoutId: identity.workoutId,
        operationId: identity.operationId,
        contractVersion: setCreateContractVersion,
        mutationKind: setCreateMutationKind,
      );

  /// Canonical, unambiguous AAD encoding: each field is a big-endian 32-bit
  /// length followed by its UTF-8 bytes, prefixed by a domain separator.
  Uint8List get associatedData {
    final builder = BytesBuilder(copy: false);
    void addField(String value) {
      final bytes = utf8.encode(value);
      final length = ByteData(4)..setUint32(0, bytes.length, Endian.big);
      builder
        ..add(length.buffer.asUint8List())
        ..add(bytes);
    }

    addField(_domain);
    addField(ownerId);
    addField(operationId);
    addField(workoutId);
    addField('$contractVersion');
    addField(mutationKind);
    return builder.takeBytes();
  }

  static void _requireText(String value, String name) {
    if (value.isEmpty || value.trim() != value) {
      throw ArgumentError.value(value, name, 'Must be non-blank and trimmed');
    }
  }
}

/// Authenticated encryption for one offline payload.
///
/// Keys live behind [OfflinePayloadKeyStore]; this type never persists them.
/// Sealing always uses [currentKeyVersion]. Opening selects the key named by
/// the envelope, so envelopes written under an older version stay readable
/// after the current version moves.
final class OfflinePayloadCipher {
  final OfflinePayloadKeyStore _keyStore;
  final AesGcm _aead;
  final Random _nonceRandom;
  int _currentKeyVersion;

  OfflinePayloadCipher({
    required OfflinePayloadKeyStore keyStore,
    int currentKeyVersion = 1,
    Random? nonceRandom,
  }) : _keyStore = keyStore,
       _currentKeyVersion = currentKeyVersion,
       _nonceRandom = nonceRandom ?? Random.secure(),
       _aead = AesGcm.with256bits() {
    if (currentKeyVersion < 1) {
      throw ArgumentError.value(currentKeyVersion, 'currentKeyVersion');
    }
  }

  /// Throws until production payload protection is approved and enabled.
  factory OfflinePayloadCipher.production({
    required OfflinePayloadKeyStore keyStore,
  }) {
    if (!productionOfflinePayloadProtectionEnabled) {
      throw StateError('Production offline payload protection is disabled');
    }
    return OfflinePayloadCipher(keyStore: keyStore);
  }

  int get currentKeyVersion => _currentKeyVersion;

  /// Moves sealing to a new key version. Existing envelopes keep their version
  /// and remain decryptable through [open].
  void promoteCurrentKeyVersion(int keyVersion) {
    if (keyVersion <= _currentKeyVersion) {
      throw ArgumentError.value(keyVersion, 'keyVersion');
    }
    _currentKeyVersion = keyVersion;
  }

  Future<OfflinePayloadEnvelope> seal({
    required OfflineWriteBinding binding,
    required Uint8List plaintext,
  }) async {
    final keyVersion = _currentKeyVersion;
    final key =
        await _keyStore.readKey(binding.ownerId, keyVersion) ??
        await _keyStore.createKey(binding.ownerId, keyVersion);
    _requireUsableKey(key, keyVersion);

    final nonce = Uint8List(OfflinePayloadEnvelope.nonceLength);
    for (var index = 0; index < nonce.length; index++) {
      nonce[index] = _nonceRandom.nextInt(256);
    }

    final SecretBox box;
    try {
      box = await _aead.encrypt(
        plaintext,
        secretKey: SecretKeyData(key.bytes),
        nonce: nonce,
        aad: binding.associatedData,
      );
    } on ArgumentError {
      throw const OfflinePayloadFormatException('Payload could not be sealed');
    }
    final ciphertextWithTag = Uint8List(
      box.cipherText.length + box.mac.bytes.length,
    )..setRange(0, box.cipherText.length, box.cipherText);
    ciphertextWithTag.setRange(
      box.cipherText.length,
      ciphertextWithTag.length,
      box.mac.bytes,
    );

    return OfflinePayloadEnvelope(
      cipherVersion: OfflinePayloadEnvelope.currentCipherVersion,
      keyVersion: keyVersion,
      nonce: nonce,
      ciphertextWithTag: ciphertextWithTag,
    );
  }

  Future<Uint8List> open({
    required OfflineWriteBinding binding,
    required OfflinePayloadEnvelope envelope,
  }) async {
    if (envelope.cipherVersion != OfflinePayloadEnvelope.currentCipherVersion) {
      throw const OfflinePayloadFormatException(
        'Unsupported payload cipher version',
      );
    }
    final key = await _keyStore.readKey(binding.ownerId, envelope.keyVersion);
    if (key == null) {
      throw const OfflinePayloadKeyUnavailableException();
    }
    _requireUsableKey(key, envelope.keyVersion);

    const tagLength = OfflinePayloadEnvelope.tagLength;
    final cipherTextLength = envelope.ciphertextWithTag.length - tagLength;
    final cipherText = envelope.ciphertextWithTag.sublist(0, cipherTextLength);
    final tag = envelope.ciphertextWithTag.sublist(cipherTextLength);

    try {
      final clearText = await _aead.decrypt(
        SecretBox(cipherText, nonce: envelope.nonce, mac: Mac(tag)),
        secretKey: SecretKeyData(key.bytes),
        aad: binding.associatedData,
      );
      return Uint8List.fromList(clearText);
    } on SecretBoxAuthenticationError {
      throw const OfflinePayloadAuthenticationException();
    } on ArgumentError {
      throw const OfflinePayloadFormatException(
        'Encrypted payload could not be decoded',
      );
    }
  }

  static void _requireUsableKey(OfflinePayloadKey key, int expectedVersion) {
    if (key.version != expectedVersion ||
        key.bytes.length != OfflinePayloadKey.length) {
      throw const OfflinePayloadKeyUnavailableException();
    }
  }
}

/// Base type for every typed payload-protection failure.
///
/// Messages never include plaintext, key material, or nonce bytes.
sealed class OfflinePayloadException implements Exception {
  final String message;

  const OfflinePayloadException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// The ciphertext, tag, or bound metadata did not authenticate.
final class OfflinePayloadAuthenticationException
    extends OfflinePayloadException {
  const OfflinePayloadAuthenticationException()
    : super('Offline payload authentication failed');
}

/// No key exists for that owner and key version, or the stored key is unusable.
final class OfflinePayloadKeyUnavailableException
    extends OfflinePayloadException {
  const OfflinePayloadKeyUnavailableException()
    : super('Offline payload key is unavailable');
}

/// The envelope columns are malformed or internally inconsistent.
final class OfflinePayloadFormatException extends OfflinePayloadException {
  const OfflinePayloadFormatException([
    super.message = 'Offline payload envelope is malformed',
  ]);
}
