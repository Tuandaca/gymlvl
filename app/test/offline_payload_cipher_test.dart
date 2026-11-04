import 'dart:convert';
import 'dart:typed_data';

import 'package:app/features/workout/data/offline_payload_cipher.dart';
import 'package:app/features/workout/data/offline_secure_key_store.dart';
import 'package:app/features/workout/data/offline_security_payload.dart';
import 'package:app/features/workout/domain/workout_write_identity.dart';
import 'package:flutter_test/flutter_test.dart';

const ownerA = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
const ownerB = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
const workoutA = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
const workoutB = 'dddddddd-dddd-dddd-dddd-dddddddddddd';
const operationA = 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';
const operationB = 'ffffffff-ffff-ffff-ffff-ffffffffffff';

const marker = 'cipher-round-trip-marker';

Uint8List payloadBytes() => Uint8List.fromList(
  utf8.encode('{"reps":987,"weight_kg":123.5,"marker":"$marker"}'),
);

OfflineWriteBinding binding({
  String ownerId = ownerA,
  String workoutId = workoutA,
  String operationId = operationA,
}) => OfflineWriteBinding(
  ownerId: ownerId,
  workoutId: workoutId,
  operationId: operationId,
  contractVersion: OfflineWriteBinding.setCreateContractVersion,
  mutationKind: OfflineWriteBinding.setCreateMutationKind,
);

Uint8List fixedKey(int fill) =>
    Uint8List.fromList(List<int>.filled(OfflinePayloadKey.length, fill));

InMemoryOfflinePayloadKeyStore seededStore(
  String ownerId,
  int keyVersion,
  Uint8List bytes,
) => InMemoryOfflinePayloadKeyStore(
  seededKeys: {
    InMemoryOfflinePayloadKeyStore.keyId(ownerId, keyVersion): bytes,
  },
);

OfflinePayloadEnvelope withTamperedCiphertext(OfflinePayloadEnvelope source) {
  final bytes = Uint8List.fromList(source.ciphertextWithTag);
  bytes[0] = bytes[0] ^ 0xff;
  return OfflinePayloadEnvelope(
    cipherVersion: source.cipherVersion,
    keyVersion: source.keyVersion,
    nonce: source.nonce,
    ciphertextWithTag: bytes,
  );
}

void main() {
  test('seal and open round-trip returns the exact original bytes', () async {
    final cipher = OfflinePayloadCipher(
      keyStore: seededStore(ownerA, 1, fixedKey(0x11)),
    );

    final envelope = await cipher.seal(
      binding: binding(),
      plaintext: payloadBytes(),
    );
    final opened = await cipher.open(binding: binding(), envelope: envelope);

    expect(opened, payloadBytes());
    expect(utf8.decode(opened), contains(marker));
    expect(envelope.cipherVersion, OfflinePayloadEnvelope.currentCipherVersion);
    expect(envelope.keyVersion, 1);
    expect(envelope.nonce, hasLength(OfflinePayloadEnvelope.nonceLength));
  });

  test(
    'sealing identical plaintext twice yields a fresh nonce and ciphertext',
    () async {
      final cipher = OfflinePayloadCipher(
        keyStore: seededStore(ownerA, 1, fixedKey(0x11)),
      );

      final first = await cipher.seal(
        binding: binding(),
        plaintext: payloadBytes(),
      );
      final second = await cipher.seal(
        binding: binding(),
        plaintext: payloadBytes(),
      );

      expect(first.nonce, isNot(second.nonce));
      expect(first.ciphertextWithTag, isNot(second.ciphertextWithTag));
      expect(
        await cipher.open(binding: binding(), envelope: first),
        payloadBytes(),
      );
      expect(
        await cipher.open(binding: binding(), envelope: second),
        payloadBytes(),
      );
    },
  );

  test('tampered ciphertext fails authentication', () async {
    final cipher = OfflinePayloadCipher(
      keyStore: seededStore(ownerA, 1, fixedKey(0x11)),
    );
    final envelope = await cipher.seal(
      binding: binding(),
      plaintext: payloadBytes(),
    );

    await expectLater(
      cipher.open(
        binding: binding(),
        envelope: withTamperedCiphertext(envelope),
      ),
      throwsA(isA<OfflinePayloadAuthenticationException>()),
    );
  });

  test(
    'wrong key material fails authentication without exposing plaintext',
    () async {
      final writer = OfflinePayloadCipher(
        keyStore: seededStore(ownerA, 1, fixedKey(0x11)),
      );
      final envelope = await writer.seal(
        binding: binding(),
        plaintext: payloadBytes(),
      );
      final reader = OfflinePayloadCipher(
        keyStore: seededStore(ownerA, 1, fixedKey(0x22)),
      );

      await expectLater(
        reader.open(binding: binding(), envelope: envelope),
        throwsA(isA<OfflinePayloadAuthenticationException>()),
      );
    },
  );

  test(
    'missing key throws key-unavailable and never returns plaintext',
    () async {
      final writer = OfflinePayloadCipher(
        keyStore: seededStore(ownerA, 1, fixedKey(0x11)),
      );
      final envelope = await writer.seal(
        binding: binding(),
        plaintext: payloadBytes(),
      );
      final reader = OfflinePayloadCipher(
        keyStore: InMemoryOfflinePayloadKeyStore(),
      );

      await expectLater(
        reader.open(binding: binding(), envelope: envelope),
        throwsA(isA<OfflinePayloadKeyUnavailableException>()),
      );
    },
  );

  test(
    'an envelope sealed for one owner cannot be opened by another',
    () async {
      final cipher = OfflinePayloadCipher(
        keyStore: InMemoryOfflinePayloadKeyStore(),
      );
      final envelopeA = await cipher.seal(
        binding: binding(ownerId: ownerA),
        plaintext: payloadBytes(),
      );

      await expectLater(
        cipher.open(
          binding: binding(ownerId: ownerB),
          envelope: envelopeA,
        ),
        throwsA(isA<OfflinePayloadKeyUnavailableException>()),
      );

      // Owner B has its own key and can still use its own queue.
      final envelopeB = await cipher.seal(
        binding: binding(ownerId: ownerB),
        plaintext: payloadBytes(),
      );
      expect(
        await cipher.open(
          binding: binding(ownerId: ownerB),
          envelope: envelopeB,
        ),
        payloadBytes(),
      );
      await expectLater(
        cipher.open(
          binding: binding(ownerId: ownerA),
          envelope: envelopeB,
        ),
        throwsA(isA<OfflinePayloadAuthenticationException>()),
      );
    },
  );

  test(
    'a v1 envelope stays readable after the current key version moves to 2',
    () async {
      final cipher = OfflinePayloadCipher(
        keyStore: InMemoryOfflinePayloadKeyStore(),
      );
      final v1 = await cipher.seal(
        binding: binding(),
        plaintext: payloadBytes(),
      );
      expect(cipher.currentKeyVersion, 1);
      expect(v1.keyVersion, 1);

      cipher.promoteCurrentKeyVersion(2);
      final v2 = await cipher.seal(
        binding: binding(),
        plaintext: payloadBytes(),
      );

      expect(cipher.currentKeyVersion, 2);
      expect(v2.keyVersion, 2);
      expect(v2.nonce, isNot(v1.nonce));
      expect(
        await cipher.open(binding: binding(), envelope: v1),
        payloadBytes(),
      );
      expect(
        await cipher.open(binding: binding(), envelope: v2),
        payloadBytes(),
      );
    },
  );

  test(
    'the envelope is bound to its operation, workout and contract version',
    () async {
      final cipher = OfflinePayloadCipher(
        keyStore: seededStore(ownerA, 1, fixedKey(0x11)),
      );
      final envelope = await cipher.seal(
        binding: binding(),
        plaintext: payloadBytes(),
      );

      await expectLater(
        cipher.open(
          binding: binding(operationId: operationB),
          envelope: envelope,
        ),
        throwsA(isA<OfflinePayloadAuthenticationException>()),
      );
      await expectLater(
        cipher.open(
          binding: binding(workoutId: workoutB),
          envelope: envelope,
        ),
        throwsA(isA<OfflinePayloadAuthenticationException>()),
      );
      final otherContract = OfflineWriteBinding(
        ownerId: ownerA,
        workoutId: workoutA,
        operationId: operationA,
        contractVersion: 2,
        mutationKind: OfflineWriteBinding.setCreateMutationKind,
      );
      await expectLater(
        cipher.open(binding: otherContract, envelope: envelope),
        throwsA(isA<OfflinePayloadAuthenticationException>()),
      );
    },
  );

  test('binding associated data is unambiguous across field boundaries', () {
    final split = OfflineWriteBinding(
      ownerId: 'aa',
      workoutId: 'bb',
      operationId: 'cc',
      contractVersion: 1,
      mutationKind: 'set_create_v1',
    );
    final merged = OfflineWriteBinding(
      ownerId: 'aab',
      workoutId: 'b',
      operationId: 'cc',
      contractVersion: 1,
      mutationKind: 'set_create_v1',
    );

    expect(split.associatedData, isNot(merged.associatedData));
  });

  test('envelope column decoding rejects partial rows and mixed rows', () {
    expect(
      OfflinePayloadEnvelope.fromColumns(
        cipherVersion: null,
        keyVersion: null,
        nonce: null,
        ciphertextWithTag: null,
        hasPlaintext: true,
      ),
      isNull,
    );
    expect(
      () => OfflinePayloadEnvelope.fromColumns(
        cipherVersion: 1,
        keyVersion: null,
        nonce: null,
        ciphertextWithTag: null,
        hasPlaintext: false,
      ),
      throwsA(isA<OfflinePayloadFormatException>()),
    );
    expect(
      () => OfflinePayloadEnvelope.fromColumns(
        cipherVersion: 1,
        keyVersion: 1,
        nonce: Uint8List(OfflinePayloadEnvelope.nonceLength),
        ciphertextWithTag: Uint8List(OfflinePayloadEnvelope.tagLength + 1),
        hasPlaintext: true,
      ),
      throwsA(isA<OfflinePayloadFormatException>()),
    );
  });

  test('production construction stays gated', () {
    expect(productionOfflinePayloadProtectionEnabled, isFalse);
    expect(
      () => OfflinePayloadCipher.production(
        keyStore: InMemoryOfflinePayloadKeyStore(),
      ),
      throwsStateError,
    );
  });

  test('set-create binding derives its version and kind from the identity', () {
    final identity = WorkoutWriteIdentity(
      ownerId: ownerA,
      workoutId: workoutA,
      operationId: operationA,
    );
    final derived = OfflineWriteBinding.setCreate(identity);

    expect(derived.ownerId, ownerA);
    expect(derived.workoutId, workoutA);
    expect(derived.operationId, operationA);
    expect(derived.contractVersion, 1);
    expect(derived.mutationKind, 'set_create_v1');
    expect(operationB, isNot(derived.operationId));
  });
}
