import 'dart:math';

class SeedableRandom {
  final Random _rng;

  SeedableRandom(int seed) : _rng = Random(seed);

  int intInRange(int minInclusive, int maxInclusive) {
    if (maxInclusive < minInclusive) return minInclusive;
    final span = maxInclusive - minInclusive + 1;
    return minInclusive + _rng.nextInt(span);
  }

  double double01() => _rng.nextDouble();

  double doubleInRange(double min, double max) {
    if (max < min) return min;
    return min + (max - min) * _rng.nextDouble();
  }

  bool boolWithProb(double pTrue) {
    final p = pTrue.clamp(0.0, 1.0);
    return _rng.nextDouble() < p;
  }

  T pick<T>(List<T> values) {
    if (values.isEmpty) {
      throw StateError('pick() called with empty list');
    }
    return values[_rng.nextInt(values.length)];
  }

  String alphaNumId({int length = 12, String prefix = 'id'}) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final sb = StringBuffer(prefix);
    sb.write('_');
    for (var i = 0; i < length; i++) {
      sb.write(chars[_rng.nextInt(chars.length)]);
    }
    return sb.toString();
  }
}
