import '../dto/time_choice_loop_snapshot.dart';
import '../dto/scoring_trace.dart';
import '../enums/option_effort.dart';
import '../enums/eligibility_reason_code.dart';
import '../enums/scoring_input_field.dart';
import '../validators/scoring_input_whitelist.dart';
import 'config/score_config_v1.dart';
import 'scoring_math.dart';
import 'scoring_trace_builder.dart';

class ScoringEngine {
  static ScoringTrace scoreSnapshot(TimeChoiceLoopSnapshot s) {
    final builder = ScoringTraceBuilder(scoreConfigVersion: ScoreV1Constants.scoringConfigVersion);

    final weights = ScoreConfigV1.weightsFor(s.ageMode, s.surface);

    final effectiveMin = s.availableTimeWindow.effectiveMin;
    final eLevel = s.energyState.level;
    final tol = ScoreV1Constants.effortToleranceForEnergyLevel(eLevel);

    final dreamPresent = s.dreamAnchor.dreamIdPresent;
    final salience = s.dreamAnchor.salience;

    final usedFields = <ScoringInputField>[
      ScoringInputField.availableTimeWindowDurationMin,
      ScoringInputField.availableTimeWindowBufferRatio,
      ScoringInputField.availableTimeWindowHardBlocksCodes,
      ScoringInputField.energyStateLevel,
      ScoringInputField.energyStateSource,
      ScoringInputField.dreamIdPresent,
      ScoringInputField.dreamHorizon,
      ScoringInputField.dreamSalience,
      ScoringInputField.parentAllowedModes,
      ScoringInputField.parentBlockedTypes,
      ScoringInputField.parentIsNowInQuietHours,
    ];

    final wl = ScoringInputWhitelist.validate(usedFields);
    if (!wl.ok) {
      throw StateError('Scoring used non-whitelisted input fields: ${wl.errors}');
    }

    final inputsHash = builder.computeInputsHash(s, usedFields);

    final scored = <ScoredCandidate>[];

    for (final o in s.frameOptions.options) {
      final gateAllowed = (!o.eligibility.hardBlockHit) && o.eligibility.isAllowedByParentFrame;
      final gateTime = (o.timeCostMin.toDouble() <= effectiveMin);

      final fitsTimeWindow = gateTime;
      final hardBlockHit = o.eligibility.hardBlockHit;

      final reasonCodes = <EligibilityReasonCode>[...o.eligibility.reasonCodes];
      if (!gateTime && !reasonCodes.contains(EligibilityReasonCode.timeOverflow)) {
        reasonCodes.add(EligibilityReasonCode.timeOverflow);
      }

      double timeFit = 0.0;
      double energyFit = 0.0;
      double directionFit = 0.0;
      double frameCompliance = 0.0;
      double total = 0.0;

      if (!gateAllowed || !gateTime) {
        timeFit = gateTime ? _timeFitScore(o.timeCostMin.toDouble(), effectiveMin) : 0.0;
        energyFit = _energyFitScore(o.effort, tol, eLevel);
        directionFit = _directionFitScore(o.worldEffectPreview.dreamDelta, dreamPresent, salience);
        frameCompliance = gateAllowed ? 1.0 : 0.0;
        total = 0.0;
      } else {
        timeFit = _timeFitScore(o.timeCostMin.toDouble(), effectiveMin);
        energyFit = _energyFitScore(o.effort, tol, eLevel);
        directionFit = _directionFitScore(o.worldEffectPreview.dreamDelta, dreamPresent, salience);
        frameCompliance = 1.0;

        total = clamp01(
          weights.wTime * timeFit +
              weights.wEnergy * energyFit +
              weights.wDirection * directionFit +
              weights.wFrame * frameCompliance,
        );
      }

      scored.add(
        ScoredCandidate(
          optionId: o.optionId,
          type: o.type,
          effort: o.effort,
          timeCostMin: o.timeCostMin,
          eligibility: CandidateEligibility(
            isAllowedByParentFrame: o.eligibility.isAllowedByParentFrame,
            fitsTimeWindow: fitsTimeWindow,
            hardBlockHit: hardBlockHit,
            reasonCodes: reasonCodes,
          ),
          timeFitScore: clamp01(timeFit),
          energyFitScore: clamp01(energyFit),
          directionFitScore: clamp01(directionFit),
          frameComplianceScore: clamp01(frameCompliance),
          weightedTotalScore: clamp01(total),
          rank: 0,
        ),
      );
    }

    final ranked = _rankDeterministically(scored);

    final selected = ranked.first;
    final runnerUp = ranked.length >= 2 ? ranked[1] : null;

    final topScore = selected.weightedTotalScore;
    final runnerUpScore = runnerUp?.weightedTotalScore ?? 0.0;
    final gap = topScore - runnerUpScore;

    final frameConfidence = _frameConfidence(
      candidatesCount: ranked.length,
      gap: gap,
    );

    return ScoringTrace(
      scoringTraceId: builder.newUuidV4(),
      scoringConfigVersion: ScoreV1Constants.scoringConfigVersion,
      snapshotId: s.snapshotId,
      computedAtUtc: DateTime.now().toUtc(),
      candidatesCount: ranked.length,
      selectedTopOptionId: selected.optionId,
      runnerUpOptionId: runnerUp?.optionId,
      inputDigest: InputDigest(inputsHash: inputsHash, usedInputFields: usedFields),
      weights: weights,
      candidates: ranked,
      decisionMetrics: DecisionMetrics(
        topScore: topScore,
        runnerUpScore: runnerUpScore,
        scoreGap: gap,
        frameConfidence: frameConfidence,
      ),
    );
  }

  static double _timeFitScore(double t, double effectiveMin) {
    if (t > effectiveMin) return 0.0;
    final u = ratio(t, effectiveMin);
    return clamp01(1.0 - u);
  }

  static int _bucketEffort(OptionEffort effort) {
    switch (effort) {
      case OptionEffort.low:
        return 1;
      case OptionEffort.medium:
        return 2;
      case OptionEffort.high:
        return 3;
    }
  }

  static double _energyFitScore(OptionEffort effort, int tol, int energyLevel) {
    final e = _bucketEffort(effort);

    if (energyLevel == 1 && effort == OptionEffort.high) {
      return 0.0;
    }

    if (e <= tol) return 1.0;

    final penalty = (e - tol) / 2.0;
    return clamp01(1.0 - penalty);
  }

  static double _directionFitScore(double dreamDelta, bool dreamPresent, double salience) {
    if (!dreamPresent) return 0.5;

    final base = clamp01((dreamDelta + 1.0) / 2.0);

    return (1.0 - salience) * 0.5 + salience * base;
  }

  static List<ScoredCandidate> _rankDeterministically(List<ScoredCandidate> list) {
    final sorted = [...list];
    sorted.sort((a, b) {
      int c;

      c = b.weightedTotalScore.compareTo(a.weightedTotalScore);
      if (c != 0) return c;

      c = b.timeFitScore.compareTo(a.timeFitScore);
      if (c != 0) return c;

      c = b.energyFitScore.compareTo(a.energyFitScore);
      if (c != 0) return c;

      c = b.directionFitScore.compareTo(a.directionFitScore);
      if (c != 0) return c;

      c = a.timeCostMin.compareTo(b.timeCostMin);
      if (c != 0) return c;

      return a.optionId.compareTo(b.optionId);
    });

    final ranked = <ScoredCandidate>[];
    for (var i = 0; i < sorted.length; i++) {
      final s = sorted[i];
      ranked.add(
        ScoredCandidate(
          optionId: s.optionId,
          type: s.type,
          effort: s.effort,
          timeCostMin: s.timeCostMin,
          eligibility: s.eligibility,
          timeFitScore: s.timeFitScore,
          energyFitScore: s.energyFitScore,
          directionFitScore: s.directionFitScore,
          frameComplianceScore: s.frameComplianceScore,
          weightedTotalScore: s.weightedTotalScore,
          rank: i + 1,
        ),
      );
    }
    return ranked;
  }

  static double _frameConfidence({required int candidatesCount, required double gap}) {
    if (candidatesCount < 2) return ScoreV1Constants.defaultSingleCandidateConf;

    final denom = (ScoreV1Constants.gapHigh - ScoreV1Constants.gapLow);
    final x = denom <= 0 ? 0.0 : clamp01((gap - ScoreV1Constants.gapLow) / denom);
    return ScoreV1Constants.confMin + x * (ScoreV1Constants.confMax - ScoreV1Constants.confMin);
  }
}
