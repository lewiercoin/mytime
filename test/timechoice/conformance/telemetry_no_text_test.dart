import 'package:flutter_test/flutter_test.dart';
import 'package:mytime/timechoice/timechoice.dart';

void main() {
  group('C.2 telemetry NO TEXT', () {
    test('TelemetryEnvelope validates and contains only ids/enums', () {
      final env = TelemetryEnvelope(
        eventId: 'evt_1',
        eventType: TelemetryEventType.loopStarted,
        timestampUtc: DateTime.now().toUtc(),
        schemaVersion: 'telemetry/v1',
        loopVersion: 'timechoice/v1',
        snapshotId: 'snap_1',
        subjectRef: 'subj_1',
        familyRef: null,
        ageMode: AgeMode.junior,
        surface: Surface.today,
        contextTrigger: ContextTrigger.generic,
        source: TelemetrySource.app,
      );

      final res = TelemetryValidator.validateEnvelope(env);
      expect(res.ok, isTrue, reason: res.errors.join('\n'));
    });

    test('LoopUpdatedEvent has no free-text fields by design', () {
      final env = TelemetryEnvelope(
        eventId: 'evt_2',
        eventType: TelemetryEventType.loopUpdated,
        timestampUtc: DateTime.now().toUtc(),
        schemaVersion: 'telemetry/v1',
        loopVersion: 'timechoice/v1',
        snapshotId: 'snap_2',
        subjectRef: 'subj_2',
        familyRef: null,
        ageMode: AgeMode.junior,
        surface: Surface.today,
        contextTrigger: ContextTrigger.generic,
        source: TelemetrySource.app,
      );

      final e = LoopUpdatedEvent(
        envelope: env,
        reflectionPresent: true,
        reflectionPromptId: 'p1',
        reflectionResponseFormat: ResponseFormat.emoji,
        reflectionResponseEnum: ReflectionResponseEnum.ok,
        parameterDeltasPresent: true,
        updatedFields: const [LearningUpdatedField.bufferAdjusted],
        preferredDurationBand: PreferredDurationBand.b20_40,
        nextFrameHintPresent: false,
      );

      expect(e.reflectionPromptId, equals('p1'));
    });
  });
}
