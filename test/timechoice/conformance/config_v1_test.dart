import 'package:flutter_test/flutter_test.dart';
import 'package:mytime/timechoice/timechoice.dart';

void main() {
  group('C.3.2 score/v1 config', () {
    test('ScoreConfigValidator.validateV1 passes', () {
      final res = ScoreConfigValidator.validateV1();
      expect(res.ok, isTrue, reason: res.errors.join('\n'));
    });
  });
}
