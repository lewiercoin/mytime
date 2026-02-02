import 'package:flutter_test/flutter_test.dart';
import 'package:mytime/timechoice/timechoice.dart';

void main() {
  group('C.7 telemetry ordering + idempotency contract', () {
    test('Ordering: E1 -> E2 -> (E3?) -> (E4?) -> E5', () {
      final s = PropertyGenerator(seed: 101).generateValidSnapshot();

      int counter = 0;
      String newId() => 'evt_${counter++}';

      final events = SnapshotToTelemetryMapper.toOrderedEvents(
        s: s,
        source: TelemetrySource.orchestrator,
        nowUtc: DateTime.now().toUtc(),
        newEventId: newId,
      );

      expect(events.first, isA<LoopStartedEvent>());
      expect(events[1], isA<FramePresentedEvent>());
      expect(events.last, isA<LoopUpdatedEvent>());

      for (var i = 2; i < events.length - 1; i++) {
        final e = events[i];
        final ok = e is OptionSelectedEvent || e is WorldOutcomeRecordedEvent;
        expect(ok, isTrue, reason: 'Unexpected middle event type: ${e.runtimeType}');
      }

      final idx3 = events.indexWhere((e) => e is OptionSelectedEvent);
      final idx4 = events.indexWhere((e) => e is WorldOutcomeRecordedEvent);
      if (idx3 != -1 && idx4 != -1) {
        expect(idx3 < idx4, isTrue);
      }
    });

    test('Idempotency: keys are based on (snapshot_id, event_type), not event_id', () {
      final s = PropertyGenerator(seed: 202).generateValidSnapshot();

      List<Object> emitOnce(int startCounter) {
        var c = startCounter;
        String newId() => 'evt_${c++}';
        return SnapshotToTelemetryMapper.toOrderedEvents(
          s: s,
          source: TelemetrySource.orchestrator,
          nowUtc: DateTime.now().toUtc(),
          newEventId: newId,
        );
      }

      final a = emitOnce(0);
      final b = emitOnce(1000);

      final aKeys = a.map((e) => TelemetryIdempotency.keyForEnvelope(TelemetryIdempotency.envelopeOf(e))).toSet();
      final bKeys = b.map((e) => TelemetryIdempotency.keyForEnvelope(TelemetryIdempotency.envelopeOf(e))).toSet();

      expect(aKeys, equals(bKeys));
    });

    test('Runner: runAndEmitTelemetry preserves ordering and produces stable idempotency keys', () {
      final s = PropertyGenerator(seed: 303).generateValidSnapshot();

      int counter = 0;
      String newId() => 'evt_${counter++}';

      final result = TimeChoiceLoopRunner.runAndEmitTelemetry(
        s: s,
        telemetrySource: TelemetrySource.orchestrator,
        nowUtc: DateTime.now().toUtc(),
        newEventId: newId,
      );

      final events = result.events;

      expect(events.first, isA<LoopStartedEvent>());
      expect(events[1], isA<FramePresentedEvent>());
      expect(events.last, isA<LoopUpdatedEvent>());

      for (final e in events) {
        final env = TelemetryIdempotency.envelopeOf(e);
        final res = TelemetryValidator.validateEnvelope(env);
        expect(res.ok, isTrue, reason: res.errors.join('\n'));
      }

      final keys = events.map((e) => TelemetryIdempotency.keyForEnvelope(TelemetryIdempotency.envelopeOf(e))).toList();
      final unique = keys.toSet();
      expect(unique.length, equals(keys.length));
    });
  });
}
