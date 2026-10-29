import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Source-configuration checks only, not a merged-manifest or APK verification.
// This small tag-stack reader supports these checked-in manifests (including
// comments); it is not a general-purpose XML parser or an Android manifest merger.
List<String> internetPermissionParents(String source) {
  final stack = <String>[];
  final parents = <String>[];
  final tokens = RegExp(r'<!--[\s\S]*?-->|<[^>]+>').allMatches(source);
  final internet = RegExp(
    'android:name\\s*=\\s*[\'"]android\\.permission\\.INTERNET[\'"]',
  );
  for (final token in tokens) {
    final tag = token.group(0)!;
    if (tag.startsWith('<!--') || tag.startsWith('<?')) continue;
    if (tag.startsWith('</')) {
      final name = RegExp(r'^</\s*([\w:.-]+)').firstMatch(tag)!.group(1);
      if (stack.isEmpty || stack.removeLast() != name) {
        throw FormatException('Unbalanced manifest tags');
      }
      continue;
    }
    final name = RegExp(r'^<([\w:.-]+)').firstMatch(tag)!.group(1)!;
    if (name == 'uses-permission' && internet.hasMatch(tag)) {
      parents.add(stack.join('/'));
      expect(tag, isNot(contains('maxSdkVersion')));
    }
    if (!tag.endsWith('/>')) stack.add(name);
  }
  expect(stack, isEmpty, reason: 'Manifest tags must close');
  return parents;
}

String? kotlinBlock(String source, String marker) {
  final start = RegExp('${RegExp.escape(marker)}\\s*\\{').firstMatch(source);
  if (start == null) return null;
  var depth = 1;
  for (var index = start.end; index < source.length; index++) {
    if (source[index] == '{') depth++;
    if (source[index] == '}') depth--;
    if (depth == 0) return source.substring(start.end, index);
  }
  throw const FormatException('Unbalanced checked-in Kotlin block');
}

void main() {
  final wrapper = File(
    'android/gradle/wrapper/gradle-wrapper.properties',
  ).readAsLinesSync();
  test('wrapper pins the approved Gradle 8.13 binary distribution', () {
    expect(wrapper.where((line) => line.startsWith('distributionUrl=')), [
      r'distributionUrl=https\://services.gradle.org/distributions/gradle-8.13-bin.zip',
    ]);
  });
  test('wrapper verifies the official Gradle 8.13 binary SHA256', () {
    // https://services.gradle.org/distributions/gradle-8.13-bin.zip.sha256
    expect(wrapper.where((line) => line.startsWith('distributionSha256Sum=')), [
      'distributionSha256Sum=20f1b1176237254a6fc204d8434196fa11a4cfb387567519c61556e8710aed78',
    ]);
  });
  final signing = File('android/app/build.gradle.kts').readAsStringSync();
  const inputs = [
    'GYMLVL_RELEASE_STORE_FILE',
    'GYMLVL_RELEASE_STORE_PASSWORD',
    'GYMLVL_RELEASE_KEY_ALIAS',
    'GYMLVL_RELEASE_KEY_PASSWORD',
  ];

  test('release signing never falls back to the development debug key', () {
    final release = kotlinBlock(
      kotlinBlock(signing, 'buildTypes')!,
      'release',
    )!;
    expect(release, isNot(contains('getByName("debug")')));
    expect(release, contains('signingConfigs.getByName("release")'));
  });

  test('operator environment supplies all four release signing inputs', () {
    for (final input in inputs) {
      expect(signing, contains('"$input"'));
    }
    expect(signing, contains('providers.environmentVariable'));
    expect(signing, contains('isNotBlank()'));
    final release = kotlinBlock(signing, 'create("release")');
    expect(release, isNotNull);
    expect(release, contains('if (missingReleaseSigning.isEmpty())'));
    for (final property in [
      'storeFile',
      'storePassword',
      'keyAlias',
      'keyPassword',
    ]) {
      expect(release, contains('$property ='));
    }
  });

  test(
    'source gates missing and partial inputs only at release packaging or signing',
    () {
      final taskNames = RegExp(
        r'val releasePackagingTasks = setOf\(([\s\S]*?)\)',
      ).firstMatch(signing);
      expect(taskNames, isNotNull);
      final names = RegExp(
        r'"([^"]+)"',
      ).allMatches(taskNames!.group(1)!).map((match) => match.group(1)).toSet();
      expect(
        names,
        containsAll([
          'validateSigningRelease',
          'packageRelease',
          'signReleaseBundle',
          'bundleRelease',
          'assembleRelease',
        ]),
      );
      expect(names, isNot(contains('processReleaseMainManifest')));
      expect(names, isNot(contains('help')));
      expect(names.where((name) => name!.contains('Debug')), isEmpty);
      final tasks = kotlinBlock(signing, 'tasks.configureEach');
      expect(tasks, contains('if (name in releasePackagingTasks)'));
      // A dependency runs even when AGP skips its signing task with onlyIf.
      expect(tasks, contains('dependsOn(validateReleaseSigningInputs)'));
      final gate = kotlinBlock(
        kotlinBlock(
              signing,
              'tasks.register("validateReleaseSigningInputs")',
            ) ??
            '',
        'doLast',
      );
      expect(gate, contains('if (missingReleaseSigning.isNotEmpty())'));
      expect(gate, contains('throw GradleException('));
    },
  );

  test(
    'signing failures list missing names without logging credential values',
    () {
      expect(
        signing,
        contains(
          'releaseSigningInputs.filter { releaseSigningValues[it] == null }',
        ),
      );
      final gate = kotlinBlock(
        kotlinBlock(
              signing,
              'tasks.register("validateReleaseSigningInputs")',
            ) ??
            '',
        'doLast',
      );
      expect(gate, isNotNull);
      expect(gate, contains(r'${missingReleaseSigning.joinToString(", ")}'));
      expect(gate, isNot(contains('releaseSigningValues')));
      expect(signing, isNot(contains('println(')));
      expect(signing, isNot(contains('logger.')));
    },
  );

  test(
    'main manifest grants INTERNET exactly once as a direct manifest child',
    () {
      final source = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
      expect(
        internetPermissionParents(source),
        ['manifest'],
        reason:
            'Release must not rely on the debug/profile permission overlays',
      );
    },
  );

  for (final variant in ['debug', 'profile']) {
    test('$variant retains its existing direct-child INTERNET permission', () {
      final source = File(
        'android/app/src/$variant/AndroidManifest.xml',
      ).readAsStringSync();
      expect(internetPermissionParents(source), ['manifest']);
    });
  }

  test(
    'source check detects duplicate and application-nested permission mistakes',
    () {
      const permission =
          '<uses-permission android:name="android.permission.INTERNET"/>';
      expect(
        internetPermissionParents(
          '<manifest>$permission$permission</manifest>',
        ),
        ['manifest', 'manifest'],
      );
      expect(
        internetPermissionParents(
          '<manifest><application>$permission</application></manifest>',
        ),
        ['manifest/application'],
      );
      expect(
        internetPermissionParents('<manifest><!-- $permission --></manifest>'),
        isEmpty,
      );
    },
  );
}
