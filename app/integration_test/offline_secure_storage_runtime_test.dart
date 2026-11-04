// M3.6 real-runtime verification of platform-backed secure key storage.
//
// This is an integration test, not part of `flutter test`. It runs in a real
// Flutter application process on a real platform backend (on Windows: the
// Credential Manager / DPAPI through flutter_secure_storage) and is executed in
// two separate processes so that "survives an app restart" is proven by a new
// process reading the key the previous process wrote.
//
// It never touches a Supabase project, a real account, or real workout data.
// Every identifier below is a synthetic test value.
//
// Usage:
//   flutter test integration_test/offline_secure_storage_runtime_test.dart -d windows \
//     --dart-define=M36_PHASE=create
//   flutter test integration_test/offline_secure_storage_runtime_test.dart -d windows \
//     --dart-define=M36_PHASE=recover
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app/features/workout/data/offline_payload_cipher.dart';
import 'package:app/features/workout/data/offline_secure_key_store.dart';
import 'package:app/features/workout/domain/workout_write_identity.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const String ownerA = 'a1000000-0000-4000-8000-0000000000a1';
const String ownerB = 'b1000000-0000-4000-8000-0000000000b1';
const String workoutA = 'c1000000-0000-4000-8000-0000000000c1';
const String operationA = 'd1000000-0000-4000-8000-0000000000d1';
const int keyVersion = 1;

/// A distinctive marker so a plaintext leak would be obvious in the artifact.
const String secretPayload =
    '{"workout_exercise_id":"e1000000-0000-4000-8000-0000000000e1",'
    '"set_number":1,"reps":7,"weight_kg":37.5,"duration_seconds":0,'
    '"rest_seconds":45,"is_completed":true,"m36_marker":"RUNTIME-SECRET-9241"}';

final String _artifactPath =
    '${Directory.systemTemp.path}${Platform.pathSeparator}'
    'gymlvl_m36_secure_storage_artifact.json';

OfflineWriteBinding _bindingFor(String ownerId) =>
    OfflineWriteBinding.setCreate(
      WorkoutWriteIdentity(
        ownerId: ownerId,
        workoutId: workoutA,
        operationId: operationA,
      ),
    );

String _sha256Hex(Uint8List bytes) => sha256.convert(bytes).toString();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final phase = const String.fromEnvironment(
    'M36_PHASE',
    defaultValue: 'create',
  );

  testWidgets('platform secure storage lifecycle [$phase]', (tester) async {
    final keyStore = PlatformSecureOfflinePayloadKeyStore();
    final cipher = OfflinePayloadCipher(
      keyStore: keyStore,
      currentKeyVersion: keyVersion,
    );
    final artifact = File(_artifactPath);

    if (phase == 'create') {
      // Start from a known-empty owner slot so the run is repeatable.
      await keyStore.deleteKeyForOwner(ownerA, keyVersion);
      await keyStore.deleteKeyForOwner(ownerB, keyVersion);
      expect(await keyStore.readKey(ownerA, keyVersion), isNull);

      // 1. Key creation.
      final created = await keyStore.createKey(ownerA, keyVersion);
      expect(created.bytes.length, OfflinePayloadKey.length);
      expect(created.version, keyVersion);

      // 2. Key retrieval from the platform store, through a brand-new store
      // instance backed by a fresh FlutterSecureStorage handle.
      final reread = await PlatformSecureOfflinePayloadKeyStore().readKey(
        ownerA,
        keyVersion,
      );
      expect(reread, isNotNull);
      final createdDigest = _sha256Hex(created.bytes);
      expect(_sha256Hex(reread!.bytes), createdDigest);

      // 3. Encrypt a payload with the platform-held key.
      final envelope = await cipher.seal(
        binding: _bindingFor(ownerA),
        plaintext: Uint8List.fromList(utf8.encode(secretPayload)),
      );

      // The envelope must not contain the marker in clear.
      expect(
        utf8.decode(envelope.ciphertextWithTag, allowMalformed: true),
        isNot(contains('RUNTIME-SECRET-9241')),
      );

      await artifact.writeAsString(
        jsonEncode({
          'ownerA': ownerA,
          'ownerB': ownerB,
          'keyVersion': keyVersion,
          'keyDigest': createdDigest,
          'cipherVersion': envelope.cipherVersion,
          'keyVersionUsed': envelope.keyVersion,
          'nonce': base64Encode(envelope.nonce),
          'ciphertextWithTag': base64Encode(envelope.ciphertextWithTag),
          'plaintextSha256': _sha256Hex(
            Uint8List.fromList(utf8.encode(secretPayload)),
          ),
          'createdByPlatformStore': true,
        }),
      );

      // Owner B must not have inherited anything from owner A.
      expect(await keyStore.readKey(ownerB, keyVersion), isNull);

      // ignore: avoid_print
      print(
        'M36_RUNTIME create: key_created=true key_digest=$createdDigest '
        'ciphertext_bytes=${envelope.ciphertextWithTag.length} '
        'nonce_bytes=${envelope.nonce.length} '
        'artifact=$_artifactPath',
      );
      return;
    }

    expect(phase, 'recover', reason: 'M36_PHASE must be create or recover');

    // 4. A NEW process recovers the key the previous process wrote.
    expect(artifact.existsSync(), isTrue, reason: 'run the create phase first');
    final record =
        jsonDecode(await artifact.readAsString()) as Map<String, dynamic>;
    final recovered = await keyStore.readKey(ownerA, keyVersion);
    expect(recovered, isNotNull, reason: 'key did not survive the restart');
    expect(
      _sha256Hex(recovered!.bytes),
      record['keyDigest'],
      reason: 'recovered key material differs from the created key',
    );

    // 5. The encrypted queue artifact from the previous process still opens.
    final envelope = OfflinePayloadEnvelope(
      cipherVersion: record['cipherVersion'] as int,
      keyVersion: record['keyVersionUsed'] as int,
      nonce: base64Decode(record['nonce'] as String),
      ciphertextWithTag: base64Decode(record['ciphertextWithTag'] as String),
    );
    final opened = await cipher.open(
      binding: _bindingFor(ownerA),
      envelope: envelope,
    );
    expect(_sha256Hex(opened), record['plaintextSha256']);
    expect(utf8.decode(opened), secretPayload);

    // 6a. Account separation: owner B has no key, so B cannot open A's envelope.
    expect(await keyStore.readKey(ownerB, keyVersion), isNull);
    await expectLater(
      cipher.open(binding: _bindingFor(ownerB), envelope: envelope),
      throwsA(isA<OfflinePayloadKeyUnavailableException>()),
    );

    // 6b. Authenticated metadata binding: the same owner and key, but a
    // different operation ID, must fail authentication rather than decrypt.
    await expectLater(
      cipher.open(
        binding: OfflineWriteBinding.setCreate(
          WorkoutWriteIdentity(
            ownerId: ownerA,
            workoutId: workoutA,
            operationId: 'd1000000-0000-4000-8000-0000000000d9',
          ),
        ),
        envelope: envelope,
      ),
      throwsA(isA<OfflinePayloadAuthenticationException>()),
    );

    // 7. Owner-scoped key deletion is explicit and fails closed afterwards.
    await keyStore.deleteKeyForOwner(ownerA, keyVersion);
    expect(await keyStore.readKey(ownerA, keyVersion), isNull);
    await expectLater(
      cipher.open(binding: _bindingFor(ownerA), envelope: envelope),
      throwsA(isA<OfflinePayloadKeyUnavailableException>()),
    );

    await artifact.delete();

    // ignore: avoid_print
    print(
      'M36_RUNTIME recover: key_survived_restart=true '
      'envelope_decrypted_after_restart=true owner_b_denied=true '
      'delete_fails_closed=true',
    );
  });
}
