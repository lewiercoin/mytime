import '../enums/option_type.dart';
import '../enums/option_effort.dart';
import '../enums/eligibility_reason_code.dart';
import '../enums/scoring_input_field.dart';

class ScoringTrace {
  final String scoringTraceId;
  final String scoringConfigVersion;
  final String snapshotId;
  final DateTime computedAtUtc;
  final int candidatesCount;
  final String selectedTopOptionId;
  final String? runnerUpOptionId;
  final InputDigest inputDigest;
  final Weights weights;
  final List<ScoredCandidate> candidates;
  final DecisionMetrics decisionMetrics;

  ScoringTrace({
    required this.scoringTraceId,
    required this.scoringConfigVersion,
    required this.snapshotId,
    required this.computedAtUtc,
    required this.candidatesCount,
    required this.selectedTopOptionId,
    required this.runnerUpOptionId,
    required this.inputDigest,
    required this.weights,
    required this.candidates,
    required this.decisionMetrics,
  });
}

class InputDigest {
  final String inputsHash;
  final List<ScoringInputField> usedInputFields;

  InputDigest({
    required this.inputsHash,
    required this.usedInputFields,
  });
}

class Weights {
  final double wTime;
  final double wEnergy;
  final double wDirection;
  final double wFrame;

  Weights({
    required this.wTime,
    required this.wEnergy,
    required this.wDirection,
    required this.wFrame,
  });
}

class ScoredCandidate {
  final String optionId;
  final OptionType type;
  final OptionEffort effort;
  final int timeCostMin;
  final CandidateEligibility eligibility;
  final double timeFitScore;
  final double energyFitScore;
  final double directionFitScore;
  final double frameComplianceScore;
  final double weightedTotalScore;
  final int rank;

  ScoredCandidate({
    required this.optionId,
    required this.type,
    required this.effort,
    required this.timeCostMin,
    required this.eligibility,
    required this.timeFitScore,
    required this.energyFitScore,
    required this.directionFitScore,
    required this.frameComplianceScore,
    required this.weightedTotalScore,
    required this.rank,
  });
}

class CandidateEligibility {
  final bool isAllowedByParentFrame;
  final bool fitsTimeWindow;
  final bool hardBlockHit;
  final List<EligibilityReasonCode> reasonCodes;

  CandidateEligibility({
    required this.isAllowedByParentFrame,
    required this.fitsTimeWindow,
    required this.hardBlockHit,
    required this.reasonCodes,
  });
}

class DecisionMetrics {
  final double topScore;
  final double runnerUpScore;
  final double scoreGap;
  final double frameConfidence;

  DecisionMetrics({
    required this.topScore,
    required this.runnerUpScore,
    required this.scoreGap,
    required this.frameConfidence,
  });
}
