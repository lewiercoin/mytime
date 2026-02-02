import 'package:flutter_test/flutter_test.dart';
import 'package:mytime/timechoice/timechoice.dart';

void main() {
  group('C.5 snapshot -> telemetry mapper', () {
    test('Mapper produces ordered events and validates envelopes', () {
      final s = PropertyGenerator(seed: 111).generateValidSnapshot();

      int counter = 0;
      String newId() => 'evt_${counter++}';

      final events = SnapshotToTelemetryMapper.toOrderedEvents(
        s: s,
        source: TelemetrySource.orchestrator,
        nowUtc: DateTime.now().toUtc(),
        newEventId: newId,
      );

      expect(events.length, greaterThanOrEqualTo(3));

      for (final e in events) {
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

        expect(env.snapshotId, equals(s.snapshotId));
        expect(env.subjectRef, equals(s.subjectRef));
        expect(env.loopVersion, equals(s.loopVersion));
      }
    });

    test('LoopUpdatedEvent never contains free text (responseEnum stays null by default)', () {
      final base = PropertyGenerator(seed: 222).generateValidSnapshot();

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
        parentFrame: base.parentFrame,
        frameOptions: base.frameOptions,
        reflection: Reflection(
          promptId: 'p1',
          responseFormat: ResponseFormat.emoji,
          responseValue: 'SHOULD_NOT_LEAK',
        ),
        learningUpdate: null,
      );

      final evt = SnapshotToTelemetryMapper.loopUpdated(
        s: s,
        source: TelemetrySource.app,
        timestampUtc: DateTime.now().toUtc(),
        eventId: 'evt_x',
      );

      expect(evt.reflectionPresent, isTrue);
      expect(evt.reflectionPromptId, equals('p1'));
      expect(evt.reflectionResponseEnum, isNull);
    });
  });
}
