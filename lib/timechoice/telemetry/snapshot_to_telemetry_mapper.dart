import '../dto/telemetry.dart';
import '../dto/time_choice_loop_snapshot.dart';
import '../enums/telemetry_source.dart';
import '../enums/telemetry_event_type.dart';
import '../enums/response_format.dart';
import '../enums/preferred_duration_band.dart';

class SnapshotToTelemetryMapper {
  static const String schemaVersion = 'telemetry/v1';

  static TelemetryEnvelope _envelope({
    required TimeChoiceLoopSnapshot s,
    required TelemetryEventType type,
    required TelemetrySource source,
    required DateTime timestampUtc,
    required String eventId,
  }) {
    return TelemetryEnvelope(
      eventId: eventId,
      eventType: type,
      timestampUtc: timestampUtc,
      schemaVersion: schemaVersion,
      loopVersion: s.loopVersion,
      snapshotId: s.snapshotId,
      subjectRef: s.subjectRef,
      familyRef: s.familyRef,
      ageMode: s.ageMode,
      surface: s.surface,
      contextTrigger: s.contextTrigger,
      source: source,
    );
  }

  static LoopStartedEvent loopStarted({
    required TimeChoiceLoopSnapshot s,
    required TelemetrySource source,
    required DateTime timestampUtc,
    required String eventId,
  }) {
    final env = _envelope(
      s: s,
      type: TelemetryEventType.loopStarted,
      source: source,
      timestampUtc: timestampUtc,
      eventId: eventId,
    );

    return LoopStartedEvent(
      envelope: env,
      durationMin: s.availableTimeWindow.durationMin,
      bufferRatio: s.availableTimeWindow.bufferRatio,
      energyLevel: s.energyState.level,
      energySource: s.energyState.source,
      dreamIdPresent: s.dreamAnchor.dreamIdPresent,
      allowedMode: s.parentFrame.allowedMode,
    );
  }

  static FramePresentedEvent framePresented({
    required TimeChoiceLoopSnapshot s,
    required TelemetrySource source,
    required DateTime timestampUtc,
    required String eventId,
  }) {
    final env = _envelope(
      s: s,
      type: TelemetryEventType.framePresented,
      source: source,
      timestampUtc: timestampUtc,
      eventId: eventId,
    );

    final options = s.frameOptions.options;

    return FramePresentedEvent(
      envelope: env,
      optionsCount: options.length,
      optionIds: options.map((o) => o.optionId).toList(),
      optionTypes: options.map((o) => o.type).toList(),
      optionEfforts: options.map((o) => o.effort).toList(),
      optionTimeCostsMin: options.map((o) => o.timeCostMin).toList(),
      frameConfidence: s.frameOptions.frameConfidence,
      childReasonCount: s.frameOptions.frameRationale.childReason.length,
      parentReasonPresent: s.frameOptions.frameRationale.parentReasonPresent,
    );
  }

  static OptionSelectedEvent? optionSelected({
    required TimeChoiceLoopSnapshot s,
    required TelemetrySource source,
    required DateTime timestampUtc,
    required String eventId,
  }) {
    final c = s.chosenOption;
    if (c == null) return null;

    final env = _envelope(
      s: s,
      type: TelemetryEventType.optionSelected,
      source: source,
      timestampUtc: timestampUtc,
      eventId: eventId,
    );

    return OptionSelectedEvent(
      envelope: env,
      selectedOptionId: c.selectedOptionId,
      decisionLatencyMs: c.decisionLatencyMs,
      choiceMode: _mapChoiceMode(c.choiceMode),
      overrideFlag: c.overrideFlag,
    );
  }

  static ChoiceModeTelemetry _mapChoiceMode(ChoiceMode m) {
    switch (m) {
      case ChoiceMode.tap:
        return ChoiceModeTelemetry.tap;
      case ChoiceMode.swipe:
        return ChoiceModeTelemetry.swipe;
      case ChoiceMode.voice:
        return ChoiceModeTelemetry.voice;
      case ChoiceMode.parentAssisted:
        return ChoiceModeTelemetry.parentAssisted;
    }
  }

  static WorldOutcomeRecordedEvent? worldOutcomeRecorded({
    required TimeChoiceLoopSnapshot s,
    required TelemetrySource source,
    required DateTime timestampUtc,
    required String eventId,
  }) {
    final w = s.worldResponse;
    if (w == null) return null;

    final env = _envelope(
      s: s,
      type: TelemetryEventType.worldOutcomeRecorded,
      source: source,
      timestampUtc: timestampUtc,
      eventId: eventId,
    );

    final moneyPresent = w.moneyDelta != null;

    return WorldOutcomeRecordedEvent(
      envelope: env,
      outcome: w.outcome,
      actualTimeSpentMin: w.actualTimeSpentMin,
      dreamProgressDelta: w.dreamProgressDelta,
      moneyDeltaPresent: moneyPresent,
      moneyDelta: moneyPresent ? w.moneyDelta : null,
      frictionEvents: w.frictionEvents,
      celebrationShown: w.celebrationShown,
    );
  }

  static LoopUpdatedEvent loopUpdated({
    required TimeChoiceLoopSnapshot s,
    required TelemetrySource source,
    required DateTime timestampUtc,
    required String eventId,
  }) {
    final env = _envelope(
      s: s,
      type: TelemetryEventType.loopUpdated,
      source: source,
      timestampUtc: timestampUtc,
      eventId: eventId,
    );

    final r = s.reflection;
    final u = s.learningUpdate;

    final reflectionPresent = r != null;
    final promptId = r?.promptId;
    final format = r?.responseFormat;

    ReflectionResponseEnum? responseEnum;
    if (r != null &&
        (r.responseFormat == ResponseFormat.emoji ||
            r.responseFormat == ResponseFormat.oneTap)) {
      responseEnum = null;
    }

    final parameterDeltasPresent = u?.parameterDeltasPresent ?? false;
    final updatedFields = u?.updatedFields ?? const [];
    final preferredDurationBand =
        u?.preferredDurationBand ?? PreferredDurationBand.b20_40;
    final nextFrameHintPresent = u?.nextFrameHintPresent ?? false;

    return LoopUpdatedEvent(
      envelope: env,
      reflectionPresent: reflectionPresent,
      reflectionPromptId: promptId,
      reflectionResponseFormat: format,
      reflectionResponseEnum: responseEnum,
      parameterDeltasPresent: parameterDeltasPresent,
      updatedFields: updatedFields,
      preferredDurationBand: preferredDurationBand,
      nextFrameHintPresent: nextFrameHintPresent,
    );
  }

  static List<Object> toOrderedEvents({
    required TimeChoiceLoopSnapshot s,
    required TelemetrySource source,
    required DateTime nowUtc,
    required String Function() newEventId,
  }) {
    final events = <Object>[];

    events.add(loopStarted(
      s: s,
      source: source,
      timestampUtc: nowUtc,
      eventId: newEventId(),
    ));

    events.add(framePresented(
      s: s,
      source: source,
      timestampUtc: nowUtc,
      eventId: newEventId(),
    ));

    final sel = optionSelected(
      s: s,
      source: source,
      timestampUtc: nowUtc,
      eventId: newEventId(),
    );
    if (sel != null) events.add(sel);

    final out = worldOutcomeRecorded(
      s: s,
      source: source,
      timestampUtc: nowUtc,
      eventId: newEventId(),
    );
    if (out != null) events.add(out);

    events.add(loopUpdated(
      s: s,
      source: source,
      timestampUtc: nowUtc,
      eventId: newEventId(),
    ));

    return events;
  }
}
