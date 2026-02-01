import '../enums/age_mode.dart';import '../enums/surface.dart';import '../enums/context_trigger.dart';import '../enums/telemetry_event_type.dart';import '../enums/telemetry_source.dart';import '../enums/option_type.dart';import '../enums/option_effort.dart';import '../enums/world_outcome.dart';import '../enums/friction_event.dart';import '../enums/response_format.dart';import '../enums/learning_updated_field.dart';import '../enums/preferred_duration_band.dart';import 'time_choice_loop_snapshot.dart' show AllowedMode, EnergySource;

class TelemetryEnvelope {
  final String eventId;
  final TelemetryEventType eventType;
  final DateTime timestampUtc;
  final String schemaVersion;
  final String loopVersion;
  final String snapshotId;
  final String subjectRef;
  final String? familyRef;
  final AgeMode ageMode;
  final Surface surface;
  final ContextTrigger contextTrigger;
  final TelemetrySource source;

  TelemetryEnvelope({
    required this.eventId,
    required this.eventType,
    required this.timestampUtc,
    required this.schemaVersion,
    required this.loopVersion,
    required this.snapshotId,
    required this.subjectRef,
    this.familyRef,
    required this.ageMode,
    required this.surface,
    required this.contextTrigger,
    required this.source,
  });
}

class LoopStartedEvent {
  final TelemetryEnvelope envelope;
  final int durationMin;
  final double bufferRatio;
  final int energyLevel;
  final EnergySource energySource;
  final bool dreamIdPresent;
  final AllowedMode allowedMode;

  LoopStartedEvent({
    required this.envelope,
    required this.durationMin,
    required this.bufferRatio,
    required this.energyLevel,
    required this.energySource,
    required this.dreamIdPresent,
    required this.allowedMode,
  });
}

class FramePresentedEvent {
  final TelemetryEnvelope envelope;
  final int optionsCount;
  final List<String> optionIds;
  final List<OptionType> optionTypes;
  final List<OptionEffort> optionEfforts;
  final List<int> optionTimeCostsMin;
  final double frameConfidence;
  final int childReasonCount;
  final bool parentReasonPresent;

  FramePresentedEvent({
    required this.envelope,
    required this.optionsCount,
    required this.optionIds,
    required this.optionTypes,
    required this.optionEfforts,
    required this.optionTimeCostsMin,
    required this.frameConfidence,
    required this.childReasonCount,
    required this.parentReasonPresent,
  });
}

class OptionSelectedEvent {
  final TelemetryEnvelope envelope;
  final String selectedOptionId;
  final int decisionLatencyMs;
  final ChoiceModeTelemetry choiceMode;
  final bool overrideFlag;

  OptionSelectedEvent({
    required this.envelope,
    required this.selectedOptionId,
    required this.decisionLatencyMs,
    required this.choiceMode,
    required this.overrideFlag,
  });
}

enum ChoiceModeTelemetry { tap, swipe, voice, parentAssisted }

class WorldOutcomeRecordedEvent {
  final TelemetryEnvelope envelope;
  final WorldOutcome outcome;
  final int actualTimeSpentMin;
  final double dreamProgressDelta;
  final bool moneyDeltaPresent;
  final int? moneyDelta;
  final List<FrictionEvent> frictionEvents;
  final bool celebrationShown;

  WorldOutcomeRecordedEvent({
    required this.envelope,
    required this.outcome,
    required this.actualTimeSpentMin,
    required this.dreamProgressDelta,
    required this.moneyDeltaPresent,
    required this.moneyDelta,
    required this.frictionEvents,
    required this.celebrationShown,
  });
}

class LoopUpdatedEvent {
  final TelemetryEnvelope envelope;
  final bool reflectionPresent;
  final String? reflectionPromptId;
  final ResponseFormat? reflectionResponseFormat;
  final ReflectionResponseEnum? reflectionResponseEnum;
  final bool parameterDeltasPresent;
  final List<LearningUpdatedField> updatedFields;
  final PreferredDurationBand preferredDurationBand;
  final bool nextFrameHintPresent;

  LoopUpdatedEvent({
    required this.envelope,
    required this.reflectionPresent,
    required this.reflectionPromptId,
    required this.reflectionResponseFormat,
    required this.reflectionResponseEnum,
    required this.parameterDeltasPresent,
    required this.updatedFields,
    required this.preferredDurationBand,
    required this.nextFrameHintPresent,
  });
}

enum ReflectionResponseEnum { easy, ok, hard }
