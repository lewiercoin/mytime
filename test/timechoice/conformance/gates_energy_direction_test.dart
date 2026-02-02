import 'package:flutter_test/flutter_test.dart';
import 'package:mytime/timechoice/timechoice.dart';

void main() {
  group('C.3.1 gates + ethics', () {
    test('G2: time_cost_min > effective_min => weighted_total_score == 0', () {
      final s = PropertyGenerator(seed: 10).generateEdgeCaseTimeOverflow(seed: 10);
      final trace = ScoringEngine.scoreSnapshot(s);

      final o0Id = s.frameOptions.options.first.optionId;
      final cand = trace.candidates.firstWhere((c) => c.optionId == o0Id);

      expect(cand.eligibility.fitsTimeWindow, isFalse);
      expect(cand.weightedTotalScore, equals(0.0));
    });

    test('G1: blocked_by_parent => weighted_total_score == 0', () {
      final base = PropertyGenerator(seed: 20).generateValidSnapshot(
        ageMode: AgeMode.junior,
        surface: Surface.today,
      );

      final blockedType = OptionType.mission;
      final pf = ParentFrame(
        allowedMode: base.parentFrame.allowedMode,
        blockedTypes: [blockedType],
        isNowInQuietHours: base.parentFrame.isNowInQuietHours,
      );

      final blockedOption = FramedOption(
        optionId: 'blocked_opt',
        type: blockedType,
        effort: OptionEffort.low,
        timeCostMin: 0,
        eligibility: Eligibility(
          isAllowedByParentFrame: false,
          fitsTimeWindow: true,
          hardBlockHit: false,
          reasonCodes: const [EligibilityReasonCode.blockedByParent],
        ),
        worldEffectPreview: WorldEffectPreview(dreamDelta: 0.0),
      );

      final allowedOption = FramedOption(
        optionId: 'allowed_opt',
        type: OptionType.rest,
        effort: OptionEffort.low,
        timeCostMin: 0,
        eligibility: Eligibility(
          isAllowedByParentFrame: true,
          fitsTimeWindow: true,
          hardBlockHit: false,
          reasonCodes: const [],
        ),
        worldEffectPreview: WorldEffectPreview(dreamDelta: 0.0),
      );

      final s = TimeChoiceLoopSnapshot(
        snapshotId: base.snapshotId,
        timestampUtc: base.timestampUtc,
        loopVersion: base.loopVersion,
        ageMode: base.ageMode,
        surface: base.surface,
        contextTrigger: base.contextTrigger,
        subjectRef: base.subjectRef,
        familyRef: base.familyRef,
        availableTimeWindow: base.availableTimeWindow,
        energyState: base.energyState,
        dreamAnchor: base.dreamAnchor,
        parentFrame: pf,
        frameOptions: FrameOptions(
          options: [blockedOption, allowedOption],
          frameConfidence: 0.5,
          frameRationale: base.frameOptions.frameRationale,
        ),
      );

      final trace = ScoringEngine.scoreSnapshot(s);
      final blocked = trace.candidates.firstWhere((c) => c.optionId == 'blocked_opt');
      expect(blocked.weightedTotalScore, equals(0.0));
    });

    test('Energy ethics: E=1 and effort=high => energy_fit_score == 0', () {
      final base = PropertyGenerator(seed: 30).generateValidSnapshot(
        dreamPresent: false,
        ageMode: AgeMode.junior,
        surface: Surface.today,
      );

      final s = TimeChoiceLoopSnapshot(
        snapshotId: base.snapshotId,
        timestampUtc: base.timestampUtc,
        loopVersion: base.loopVersion,
        ageMode: base.ageMode,
        surface: base.surface,
        contextTrigger: base.contextTrigger,
        subjectRef: base.subjectRef,
        familyRef: base.familyRef,
        availableTimeWindow: base.availableTimeWindow,
        energyState: EnergyState(level: 1, source: EnergySource.selfReported, confidence: 1.0),
        dreamAnchor: base.dreamAnchor,
        parentFrame: base.parentFrame,
        frameOptions: FrameOptions(
          options: [
            FramedOption(
              optionId: 'hi_eff',
              type: OptionType.mission,
              effort: OptionEffort.high,
              timeCostMin: 0,
              eligibility: Eligibility(
                isAllowedByParentFrame: true,
                fitsTimeWindow: true,
                hardBlockHit: false,
                reasonCodes: const [],
              ),
              worldEffectPreview: WorldEffectPreview(dreamDelta: 0.0),
            ),
          ],
          frameConfidence: 0.5,
          frameRationale: base.frameOptions.frameRationale,
        ),
      );

      final trace = ScoringEngine.scoreSnapshot(s);
      final c = trace.candidates.first;
      expect(c.energyFitScore, equals(0.0));
    });

    test('Direction non-tyranny: dream_present=false => direction_fit_score == 0.5', () {
      final base = PropertyGenerator(seed: 40).generateValidSnapshot(
        dreamPresent: false,
        ageMode: AgeMode.junior,
        surface: Surface.today,
      );

      final trace = ScoringEngine.scoreSnapshot(base);
      for (final c in trace.candidates) {
        expect(c.directionFitScore, equals(0.5));
      }
    });
  });
}
