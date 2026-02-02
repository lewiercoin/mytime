import 'package:flutter_test/flutter_test.dart';
import 'package:mytime/timechoice/timechoice.dart';

void main() {
  group('C.6 TimeChoiceLoopRunner', () {
    test('attachScoringTrace attaches trace and sets frameConfidence from trace', () {
      final s = PropertyGenerator(seed: 555).generateValidSnapshot();

      final out = TimeChoiceLoopRunner.attachScoringTrace(s);

      expect(out.frameOptions.scoringTrace, isNotNull);
      final trace = out.frameOptions.scoringTrace!;
      expect(out.frameOptions.frameConfidence, equals(trace.decisionMetrics.frameConfidence));
    });

    test('attachScoringTrace is deterministic for decision outputs', () {
      final s = PropertyGenerator(seed: 777).generateValidSnapshot();

      final a = TimeChoiceLoopRunner.attachScoringTrace(s);
      final b = TimeChoiceLoopRunner.attachScoringTrace(s);

      expect(a.frameOptions.scoringTrace!.selectedTopOptionId,
          equals(b.frameOptions.scoringTrace!.selectedTopOptionId));
      expect(a.frameOptions.scoringTrace!.runnerUpOptionId,
          equals(b.frameOptions.scoringTrace!.runnerUpOptionId));
      expect(a.frameOptions.frameConfidence, equals(b.frameOptions.frameConfidence));
    });

    test('runAndEmitTelemetry emits valid envelopes', () {
      final s = PropertyGenerator(seed: 888).generateValidSnapshot();

      int counter = 0;
      String newId() => 'evt_${counter++}';

      final result = TimeChoiceLoopRunner.runAndEmitTelemetry(
        s: s,
        telemetrySource: TelemetrySource.orchestrator,
        nowUtc: DateTime.now().toUtc(),
        newEventId: newId,
      );

      expect(result.snapshot.frameOptions.scoringTrace, isNotNull);
      expect(result.events.length, greaterThanOrEqualTo(3));

      for (final e in result.events) {
        final env = switch (e) {
          LoopStartedEvent x => x.envelope,
          FramePresentedEvent x => x.envelope,
          OptionSelectedEvent x => x.envelope,
          WorldOutcomeRecordedEvent x => x.envelope,
          LoopUpdatedEvent x => x.envelope,
          _ => throw StateError('Unknown event type'),
        };

        final res = TelemetryValidator.validateEnvelope(env);
        expect(res.ok, isTrue, reason: res.errors.join('\n'));
      }
    });
  });
}
