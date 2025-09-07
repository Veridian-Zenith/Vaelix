// Lightweight EasyList-like filter parser (very small subset)
class FilterList {
  final List<String> _contains = [];
  final List<String> _hosts = [];

  FilterList();

  void addRule(String rule) {
    rule = rule.trim();
    if (rule.isEmpty) return;
    if (rule.startsWith('||')) {
      // Host-based rule, e.g. ||example.com
      final host = rule.substring(2).split('/').first;
      _hosts.add(host.toLowerCase());
    } else if (rule.startsWith('!')) {
      // comment, ignore
      return;
    } else {
      // fallback: substring
      _contains.add(rule.toLowerCase());
    }
  }

  bool matches(String url) {
    final u = url.toLowerCase();
    for (final h in _hosts) {
      if (u.contains(h)) return true;
    }
    for (final c in _contains) {
      if (u.contains(c)) return true;
    }
    return false;
  }

  static FilterList fromLines(Iterable<String> lines) {
    final f = FilterList();
    for (final l in lines) {
      final s = l.trim();
      if (s.isEmpty) continue;
      if (s.startsWith('!')) continue;
      f.addRule(s);
    }
    return f;
  }
}
