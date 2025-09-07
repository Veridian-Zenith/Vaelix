// Minimal, pure-Dart privacy engine prototype.
// Exposes a synchronous API suitable for running inside an isolate.

import 'package:flutter/services.dart' show rootBundle;
import 'package:vaelix/privacy_engine/filter_list.dart';

// A minimal manager for filter lists. In production this would be updated from remote
// sources (EasyList, EasyPrivacy, etc.) and be more sophisticated (regex, exceptions, options).
class PrivacyEngine {
  final FilterList _filters = FilterList();

  PrivacyEngine() {
    // seed with a few common trackers for phase 1
    _filters.addRule('||doubleclick.net');
    _filters.addRule('||googlesyndication.com');
    _filters.addRule('/ads/');
    _filters.addRule('tracker');
  }

  /// Load additional rules from an assets file with one rule per line.
  /// Lines starting with '!' are ignored (comments).
  Future<void> loadFromAsset(String assetPath) async {
    try {
      final data = await rootBundle.loadString(assetPath);
      final lines = data.split(RegExp(r"\r?\n"));
      for (final l in lines) {
        final s = l.trim();
        if (s.isEmpty) continue;
        if (s.startsWith('!')) continue;
        _filters.addRule(s);
      }
    } catch (e) {
      // ignore asset load failures; engine still works with built-in seeds
    }
  }

  bool shouldBlock(String url, String pageUrl) {
    if (_filters.matches(url)) return true;
    // fallback heuristics
    final blockers = ['ads.', 'adservice', 'googlesyndication'];
    final lower = url.toLowerCase();
    for (final b in blockers) if (lower.contains(b)) return true;
    return false;
  }
}

final defaultPrivacyEngine = PrivacyEngine();

bool shouldBlockRequestSync(String url, String pageUrl) {
  return defaultPrivacyEngine.shouldBlock(url, pageUrl);
}

/// Async initializer to be called at app startup to load asset-based rules.
Future<void> initializePrivacyEngine({
  String assetPath = 'assets/adblock/hosts.txt',
}) async {
  await defaultPrivacyEngine.loadFromAsset(assetPath);
}
