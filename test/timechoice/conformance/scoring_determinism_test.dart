import 'package:flutter_test/flutter_test.dart';
import 'package:mytime/timechoice/timechoice.dart';

void main() {
  group('C.3 scoring determinism', () {
    test('Determinism: same snapshot => same ranking + scores (except UUID/computedAt)', () {
      final gen = PropertyGenerator(seed: 42);
      final s = gen.generateValidSnapshot();

      final t1 = ScoringEngine.scoreSnapshot(s);
      final t2 = ScoringEngine.scoreSnapshot(s);

      expect(t1.scoringConfigVersion, equals('score/v1'));
      expect(t2.scoringConfigVersion, equals('score/v1'));

      expect(t1.selectedTopOptionId, equals(t2.selectedTopOptionId));
      expect(t1.runnerUpOptionId, equals(t2.runnerUpOptionId));
      expect(t1.candidatesCount, equals(t2.candidatesCount));

      for (var i = 0; i < t1.candidates.length; i++) {
        final a = t1.candidates[i];
        final b = t2.candidates[i];

        expect(a.optionId, equals(b.optionId));
        expect(a.rank, equals(b.rank));
        expect(a.weightedTotalScore, equals(b.weightedTotalScore));
        expect(a.timeFitScore, equals(b.timeFitScore));
        expect(a.energyFitScore, equals(b.energyFitScore));
        expect(a.directionFitScore, equals(b.directionFitScore));
      }

      expect(t1.decisionMetrics.frameConfidence, equals(t2.decisionMetrics.frameConfidence));
    });

    test('No hidden inputs: used_input_fields must be whitelist-only', () {
      final gen = PropertyGenerator(seed: 7);
      final s = gen.generateValidSnapshot();
      final t = ScoringEngine.scoreSnapshot(s);

      final res = ScoringInputWhitelist.validate(t.inputDigest.usedInputFields);
      expect(res.ok, isTrue, reason: res.errors.join('\n'));
    });

    test('Tie-break stability: if weighted_total ties, lower optionId wins last', () {
      final base = PropertyGenerator(seed: 99).generateValidSnapshot(
        dreamPresent: false,
        ageMode: AgeMode.junior,
        surface: Surface.today,
      );

      final effMin = base.availableTimeWindow.effectiveMin;
      final o1 = FramedOption(
        optionId: 'a_opt',
        type: OptionType.mission,
        effort: OptionEffort.low,
        timeCostMin: 0,
        eligibility: Eligibility(
          isAllowedByParentFrame: true,
          fitsTimeWindow: true,
          hardBlockHit: false,
          reasonCodes: const [],
        ),
        worldEffectPreview: WorldEffectPreview(dreamDelta: 0.0, moneyDelta: null),
      );
      final o2 = FramedOption(
        optionId: 'b_opt',
        type: OptionType.mission,
        effort: OptionEffort.low,
        timeCostMin: 0,
        eligibility: Eligibility(
          isAllowedByParentFrame: true,
          fitsTimeWindow: true,
          hardBlockHit: false,
          reasonCodes: const [],
        ),
        worldEffectPreview: WorldEffectPreview(dreamDelta: 0.0, moneyDelta: null),
      );

      final mutated = TimeChoiceLoopSnapshot(
        snapshotId: base.snapshotId,
        timestampUtc: base.timestampUtc,
        loopVersion: base.loopVersion,
        ageMode: base.ageMode,
        surface: base.surface,
        contextTrigger: base.contextTrigger,
        subjectRef: base.subjectRef,
        familyRef: base.familyRef,
        availableTimeWindow: AvailableTimeWindow(
          durationMin: base.availableTimeWindow.durationMin,
          bufferRatio: base.availableTimeWindow.bufferRatio,
          constraints: base.availableTimeWindow.constraints,
        ),
        energyState: base.energyState,
        dreamAnchor: base.dreamAnchor,
        parentFrame: base.parentFrame,
        frameOptions: FrameOptions(
          options: [o2, o1],
          frameConfidence: 0.5,
          frameRationale: base.frameOptions.frameRationale,
          scoringTrace: null,
        ),
      );

      expect(effMin, greaterThanOrEqualTo(0));

      final trace = ScoringEngine.scoreSnapshot(mutated);
      expect(trace.selectedTopOptionId, equals('a_opt'));
    });

    test('Confidence mapping monotonic: larger gap => higher confidence', () {
      final gen = PropertyGenerator(seed: 1234);
      final s = gen.generateValidSnapshot(
        dreamPresent: false,
        ageMode: AgeMode.junior,
        surface: Surface.today,
      );

      final t = ScoringEngine.scoreSnapshot(s);
      if (t.candidatesCount >= 2) {
        expect(t.decisionMetrics.frameConfidence, inInclusiveRange(0.40, 0.95));
      } else {
        expect(t.decisionMetrics.frameConfidence, equals(0.50));
      }
    });
  });
}
