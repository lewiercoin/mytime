import 'package:flutter_test/flutter_test.dart';
import 'package:mytime/timechoice/timechoice.dart';

void main() {
  group('C.1 Snapshot invariants', () {
    test('PropertyGenerator generates valid snapshots (seeded)', () {
      final gen = PropertyGenerator(seed: 123);
      for (var i = 0; i < 50; i++) {
        final s = gen.generateValidSnapshot();
        final res = SnapshotValidator.validate(s);
        expect(res.ok, isTrue, reason: res.errors.join('\n'));
      }
    });

    test('Judgement lint fails on child_reason containing banned words', () {
      final gen = PropertyGenerator(seed: 1);
      final s0 = gen.generateValidSnapshot();
      final mutated = TimeChoiceLoopSnapshot(
        snapshotId: s0.snapshotId,
        timestampUtc: s0.timestampUtc,
        loopVersion: s0.loopVersion,
        ageMode: s0.ageMode,
        surface: s0.surface,
        contextTrigger: s0.contextTrigger,
        subjectRef: s0.subjectRef,
        familyRef: s0.familyRef,
        availableTimeWindow: s0.availableTimeWindow,
        energyState: s0.energyState,
        dreamAnchor: s0.dreamAnchor,
        parentFrame: s0.parentFrame,
        frameOptions: FrameOptions(
          options: s0.frameOptions.options,
          frameConfidence: s0.frameOptions.frameConfidence,
          frameRationale: FrameRationale(
            childReason: const ['powinieneś to zrobić'], // banned
            parentReasonPresent: false,
          ),
          scoringTrace: s0.frameOptions.scoringTrace,
        ),
        chosenOption: s0.chosenOption,
        worldResponse: s0.worldResponse,
        reflection: s0.reflection,
        learningUpdate: s0.learningUpdate,
      );

      final res = SnapshotValidator.validate(mutated);
      expect(res.ok, isFalse);
    });
  });
}
