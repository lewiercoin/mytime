class JudgementLint {
  static const List<String> bannedSubstrings = [
    'lenistw',
    'powiniene',
    'zły wybór',
    'marnujesz',
    'musisz',
    'wstyd',
    'kara',
  ];

  static bool containsJudgement(String s) {
    final lower = s.toLowerCase();
    for (final token in bannedSubstrings) {
      if (lower.contains(token)) return true;
    }
    return false;
  }
}
