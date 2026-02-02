import '../dto/orchestrator_output_v1.dart';
import '../dto/time_choice_loop_snapshot.dart';
import '../dto/scoring_trace.dart';
import '../enums/telemetry_source.dart';
import '../timechoice_loop_runner.dart';

typedef BeforeDecideHook = void Function(TimeChoiceLoopSnapshot snapshot);
typedef AfterDecideHook = void Function(
  OrchestratorOutputV1 output,
  TimeChoiceLoopSnapshot snapshotWithTrace,
);
typedef TelemetryReadyHook = void Function(List<Object> events);

class OrchestratorResultV1 {
  final OrchestratorOutputV1 output;
  final TimeChoiceLoopSnapshot snapshotWithTrace;

  /// If telemetry emission was requested, this contains the emitted events,
  /// otherwise empty list.
  final List<Object> events;

  OrchestratorResultV1({
    required this.output,
    required this.snapshotWithTrace,
    required List<Object> events,
  }) : events = List.unmodifiable(events);
}

class TimeChoiceOrchestratorV1 {
  final BeforeDecideHook? onBeforeDecide;
  final AfterDecideHook? onAfterDecide;
  final TelemetryReadyHook? onTelemetryReady;

  const TimeChoiceOrchestratorV1({
    this.onBeforeDecide,
    this.onAfterDecide,
    this.onTelemetryReady,
  });

  OrchestratorResultV1 decide({
    required TimeChoiceLoopSnapshot snapshot,
    required DateTime nowUtc,
    required String Function() newId,
    bool emitTelemetry = false,
    TelemetrySource telemetrySource = TelemetrySource.orchestrator,
  }) {
    onBeforeDecide?.call(snapshot);

    // C.6: materialize scoringTrace + frameConfidence into the snapshot.
    final snapWithTrace = TimeChoiceLoopRunner.attachScoringTrace(snapshot);

    final trace = snapWithTrace.frameOptions.scoringTrace;
    if (trace == null) {
      throw StateError('Expected scoringTrace after attachScoringTrace().');
    }

    final mainId = _mainOptionIdWithFallback(
      snapshot: snapWithTrace,
      trace: trace,
    );

    final alternatives = _alternatives(
      snapshot: snapWithTrace,
      trace: trace,
      mainOptionId: mainId,
      maxAlternatives: 2,
    );

    List<Object> events = const [];
    int emittedCount = 0;

    if (emitTelemetry) {
      final run = TimeChoiceLoopRunner.runAndEmitTelemetry(
        s: snapshot,
        telemetrySource: telemetrySource,
        nowUtc: nowUtc,
        newEventId: newId,
      );

      events = run.events;
      emittedCount = events.length;
      onTelemetryReady?.call(events);
    }

    final out = OrchestratorOutputV1(
      snapshotId: snapWithTrace.snapshotId,
      subjectRef: snapWithTrace.subjectRef,
      familyRef: snapWithTrace.familyRef,
      ageMode: snapWithTrace.ageMode,
      surface: snapWithTrace.surface,
      contextTrigger: snapWithTrace.contextTrigger,
      mainOptionId: mainId,
      alternativeOptionIds: alternatives,
      frameConfidence: snapWithTrace.frameOptions.frameConfidence,
      scoringConfigVersion: trace.scoringConfigVersion,
      inputsHash: trace.inputDigest.inputsHash,
      telemetryEmittedCount: emittedCount,
    );

    onAfterDecide?.call(out, snapWithTrace);

    return OrchestratorResultV1(
      output: out,
      snapshotWithTrace: snapWithTrace,
      events: events,
    );
  }

  static String _mainOptionIdWithFallback({
    required TimeChoiceLoopSnapshot snapshot,
    required ScoringTrace trace,
  }) {
    // Primary: scoring trace winner if it exists in frame options.
    final top = trace.selectedTopOptionId;
    final exists = snapshot.frameOptions.options.any((o) => o.optionId == top);

    if (top.isNotEmpty && exists) return top;

    // Fallback: first option in the snapshot, stable + deterministic.
    if (snapshot.frameOptions.options.isEmpty) {
      throw StateError('No frame options available for fallback mainOptionId.');
    }
    return snapshot.frameOptions.options.first.optionId;
  }

  static List<String> _alternatives({
    required TimeChoiceLoopSnapshot snapshot,
    required ScoringTrace trace,
    required String mainOptionId,
    required int maxAlternatives,
  }) {
    final allowedIds = snapshot.frameOptions.options.map((o) => o.optionId).toSet();

    final ranked = [...trace.candidates]..sort((a, b) => a.rank.compareTo(b.rank));

    final picked = <String>[];
    for (final c in ranked) {
      if (picked.length >= maxAlternatives) break;
      if (c.optionId == mainOptionId) continue;
      if (!allowedIds.contains(c.optionId)) continue;
      if (picked.contains(c.optionId)) continue;
      picked.add(c.optionId);
    }

    return picked;
  }
}
