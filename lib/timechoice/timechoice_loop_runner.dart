import 'dto/time_choice_loop_snapshot.dart';
import 'dto/scoring_trace.dart';
import 'enums/telemetry_source.dart';
import 'scoring/scoring_engine.dart';
import 'telemetry/snapshot_to_telemetry_mapper.dart';

class TimeChoiceLoopRunner {
  static TimeChoiceLoopSnapshot attachScoringTrace(TimeChoiceLoopSnapshot s) {
    final ScoringTrace trace = ScoringEngine.scoreSnapshot(s);

    final updatedFrame = FrameOptions(
      options: s.frameOptions.options,
      frameConfidence: trace.decisionMetrics.frameConfidence,
      frameRationale: s.frameOptions.frameRationale,
      scoringTrace: trace,
    );

    return TimeChoiceLoopSnapshot(
      snapshotId: s.snapshotId,
      timestampUtc: s.timestampUtc,
      loopVersion: s.loopVersion,
      ageMode: s.ageMode,
      surface: s.surface,
      contextTrigger: s.contextTrigger,
      subjectRef: s.subjectRef,
      familyRef: s.familyRef,
      availableTimeWindow: s.availableTimeWindow,
      energyState: s.energyState,
      dreamAnchor: s.dreamAnchor,
      parentFrame: s.parentFrame,
      frameOptions: updatedFrame,
      chosenOption: s.chosenOption,
      worldResponse: s.worldResponse,
      reflection: s.reflection,
      learningUpdate: s.learningUpdate,
    );
  }

  static ({TimeChoiceLoopSnapshot snapshot, List<Object> events}) runAndEmitTelemetry({
    required TimeChoiceLoopSnapshot s,
    required TelemetrySource telemetrySource,
    required DateTime nowUtc,
    required String Function() newEventId,
  }) {
    final snapWithTrace = attachScoringTrace(s);

    final events = SnapshotToTelemetryMapper.toOrderedEvents(
      s: snapWithTrace,
      source: telemetrySource,
      nowUtc: nowUtc,
      newEventId: newEventId,
    );

    return (snapshot: snapWithTrace, events: events);
  }
}
