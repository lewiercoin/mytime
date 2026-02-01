import '../enums/age_mode.dart';
import '../enums/surface.dart';
import '../enums/context_trigger.dart';
import '../enums/option_type.dart';
import '../enums/option_effort.dart';
import '../enums/world_outcome.dart';
import '../enums/response_format.dart';
import '../enums/friction_event.dart';
import '../enums/learning_updated_field.dart';
import '../enums/preferred_duration_band.dart';
import '../enums/eligibility_reason_code.dart';
import 'scoring_trace.dart';

class TimeChoiceLoopSnapshot {
  final String snapshotId;
  final DateTime timestampUtc;
  final String loopVersion;
  final AgeMode ageMode;
  final Surface surface;
  final ContextTrigger contextTrigger;
  final String subjectRef;
  final String? familyRef;
  final AvailableTimeWindow availableTimeWindow;
  final EnergyState energyState;
  final DreamAnchor dreamAnchor;
  final ParentFrame parentFrame;
  final FrameOptions frameOptions;
  final ChosenOption? chosenOption;
  final WorldResponse? worldResponse;
  final Reflection? reflection;
  final LearningUpdate? learningUpdate;

  TimeChoiceLoopSnapshot({
    required this.snapshotId,
    required this.timestampUtc,
    required this.loopVersion,
    required this.ageMode,
    required this.surface,
    required this.contextTrigger,
    required this.subjectRef,
    this.familyRef,
    required this.availableTimeWindow,
    required this.energyState,
    required this.dreamAnchor,
    required this.parentFrame,
    required this.frameOptions,
    this.chosenOption,
    this.worldResponse,
    this.reflection,
    this.learningUpdate,
  });
}

class AvailableTimeWindow {
  final int durationMin;
  final double bufferRatio;
  final TimeConstraints constraints;

  AvailableTimeWindow({
    required this.durationMin,
    required this.bufferRatio,
    required this.constraints,
  });

  double get effectiveMin => durationMin * (1.0 - bufferRatio);
}

class TimeConstraints {
  final List<String> hardBlocksCodes;
  TimeConstraints({required this.hardBlocksCodes});
}

class EnergyState {
  final int level;
  final EnergySource source;
  final double confidence;

  EnergyState({
    required this.level,
    required this.source,
    required this.confidence,
  });
}

enum EnergySource { selfReported, inferred, mixed }

class DreamAnchor {
  final String? dreamId;
  final DreamHorizon horizon;
  final double salience;
  final DreamProgress progress;

  DreamAnchor({
    required this.dreamId,
    required this.horizon,
    required this.salience,
    required this.progress,
  });

  bool get dreamIdPresent => dreamId != null;
}

enum DreamHorizon { days, weeks, months }

class DreamProgress {
  final double value;
  DreamProgress({required this.value});
}

class ParentFrame {
  final AllowedMode allowedMode;
  final List<OptionType> blockedTypes;
  final bool isNowInQuietHours;

  ParentFrame({
    required this.allowedMode,
    required this.blockedTypes,
    required this.isNowInQuietHours,
  });
}

enum AllowedMode { offlineOnly, mixed, screenAllowed }

class FrameOptions {
  final List<FramedOption> options;
  final double frameConfidence;
  final FrameRationale frameRationale;
  final ScoringTrace? scoringTrace;

  FrameOptions({
    required this.options,
    required this.frameConfidence,
    required this.frameRationale,
    this.scoringTrace,
  });
}

class FrameRationale {
  final List<String> childReason;
  final bool parentReasonPresent;

  FrameRationale({
    required this.childReason,
    required this.parentReasonPresent,
  });
}

class FramedOption {
  final String optionId;
  final OptionType type;
  final OptionEffort effort;
  final int timeCostMin;
  final Eligibility eligibility;
  final WorldEffectPreview worldEffectPreview;

  FramedOption({
    required this.optionId,
    required this.type,
    required this.effort,
    required this.timeCostMin,
    required this.eligibility,
    required this.worldEffectPreview,
  });
}

class Eligibility {
  final bool isAllowedByParentFrame;
  final bool fitsTimeWindow;
  final bool hardBlockHit;
  final List<EligibilityReasonCode> reasonCodes;

  Eligibility({
    required this.isAllowedByParentFrame,
    required this.fitsTimeWindow,
    required this.hardBlockHit,
    required this.reasonCodes,
  });
}

class WorldEffectPreview {
  final double dreamDelta;
  final int? moneyDelta;

  WorldEffectPreview({
    required this.dreamDelta,
    this.moneyDelta,
  });
}

class ChosenOption {
  final String selectedOptionId;
  final int decisionLatencyMs;
  final ChoiceMode choiceMode;
  final bool overrideFlag;

  ChosenOption({
    required this.selectedOptionId,
    required this.decisionLatencyMs,
    required this.choiceMode,
    required this.overrideFlag,
  });
}

enum ChoiceMode { tap, swipe, voice, parentAssisted }

class WorldResponse {
  final WorldOutcome outcome;
  final int actualTimeSpentMin;
  final double dreamProgressDelta;
  final int? moneyDelta;
  final List<FrictionEvent> frictionEvents;
  final bool celebrationShown;

  WorldResponse({
    required this.outcome,
    required this.actualTimeSpentMin,
    required this.dreamProgressDelta,
    this.moneyDelta,
    required this.frictionEvents,
    required this.celebrationShown,
  });
}

class Reflection {
  final String promptId;
  final ResponseFormat responseFormat;
  final String responseValue;

  Reflection({
    required this.promptId,
    required this.responseFormat,
    required this.responseValue,
  });
}

class LearningUpdate {
  final bool parameterDeltasPresent;
  final List<LearningUpdatedField> updatedFields;
  final PreferredDurationBand preferredDurationBand;
  final bool nextFrameHintPresent;
  final String? nextFrameHint;

  LearningUpdate({
    required this.parameterDeltasPresent,
    required this.updatedFields,
    required this.preferredDurationBand,
    required this.nextFrameHintPresent,
    this.nextFrameHint,
  });
}
