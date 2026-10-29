import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// FND-INTG-001: the Auth allowlist in supabase/config.toml must match the redirect
// URL the Flutter client actually uses. These are source/configuration checks; they
// do not replace a live Auth round-trip.

String _read(String path) => File(path).readAsStringSync();

String _tomlString(String source, String key) {
  final match = RegExp(
    '^\\s*$key\\s*=\\s*"([^"]*)"',
    multiLine: true,
  ).firstMatch(source);
  if (match == null) throw StateError('Missing "$key" in config.toml');
  return match.group(1)!;
}

List<String> _tomlStringArray(String source, String key) {
  // The array ends at a `]` that starts its own line, so IPv6 hosts such as
  // `http://[::1]:8080` inside quoted entries are not mistaken for the end.
  final match = RegExp(
    '^\\s*$key\\s*=\\s*\\[([\\s\\S]*?)\\n\\s*\\]',
    multiLine: true,
  ).firstMatch(source);
  if (match == null) throw StateError('Missing "$key" in config.toml');
  return RegExp(
    r'"([^"]*)"',
  ).allMatches(match.group(1)!).map((entry) => entry.group(1)!).toList();
}

String _origin(String url) {
  final uri = Uri.parse(url);
  return '${uri.scheme}://${uri.authority}';
}

bool _isAllowlisted(String redirect, List<String> allowlist) {
  final normalized = redirect.endsWith('/')
      ? redirect.substring(0, redirect.length - 1)
      : redirect;
  for (final entry in allowlist) {
    if (entry == redirect) return true;
    final entryWithoutSlash = entry.endsWith('/')
        ? entry.substring(0, entry.length - 1)
        : entry;
    if (entryWithoutSlash == normalized) return true;
    if (entry.endsWith('/**') &&
        _origin(entry.substring(0, entry.length - 3)) == _origin(redirect)) {
      return true;
    }
  }
  return false;
}

void main() {
  final config = _read('../supabase/config.toml');
  final example =
      jsonDecode(_read('config.example.json')) as Map<String, dynamic>;
  final siteUrl = _tomlString(config, 'site_url');
  final additional = _tomlStringArray(config, 'additional_redirect_urls');
  final allowlist = [siteUrl, ...additional];
  final redirect = example['AUTH_REDIRECT_URL'] as String?;

  test('the documented dev origin is the configured Auth site URL', () {
    expect(siteUrl, 'http://localhost:8080');
    expect(_origin(siteUrl), 'http://localhost:8080');
  });

  test('the client redirect target is allowlisted', () {
    expect(redirect, isNotNull);
    expect(redirect, isNotEmpty);
    expect(
      _isAllowlisted(redirect!, allowlist),
      isTrue,
      reason: '$redirect must appear in site_url or additional_redirect_urls',
    );
  });

  test('both localhost and loopback dev origins stay allowlisted', () {
    expect(_isAllowlisted('http://localhost:8080/', allowlist), isTrue);
    expect(_isAllowlisted('http://127.0.0.1:8080/', allowlist), isTrue);
  });

  test('legacy local-server origins are preserved', () {
    expect(_isAllowlisted('http://127.0.0.1:3000', allowlist), isTrue);
  });

  test('recovery redirects allow the query string Supabase appends', () {
    expect(
      allowlist.any((entry) => entry.contains('localhost:8080/**')),
      isTrue,
      reason: 'the ?code= recovery link needs a glob entry for the dev origin',
    );
  });

  test('documented run commands serve the allowlisted origin', () {
    for (final path in ['../README.md', '../docs/DEVELOPMENT.md']) {
      final docs = _read(path);
      expect(
        docs,
        contains('--web-port 8080'),
        reason: '$path must start the client on the allowlisted port',
      );
    }
    expect(_read('lib/main.dart'), contains('--web-port 8080'));
  });
}
