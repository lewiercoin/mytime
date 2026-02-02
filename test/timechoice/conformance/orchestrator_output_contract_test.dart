import 'package:flutter_test/flutter_test.dart';
import 'package:mytime/timechoice/timechoice.dart';

void main() {
  group('D.1 orchestrator output contract (v1)', () {
    test('Determinism: same snapshot -> same output fields', () {
      final gen = PropertyGenerator(seed: 4242);
      final s = gen.generateValidSnapshot();

      final orch = TimeChoiceOrchestratorV1();

      int i1 = 0;
      final r1 = orch.decide(
        snapshot: s,
        nowUtc: DateTime.utc(2026, 1, 1),
        newId: () => 'id_${i1++}',
        emitTelemetry: false,
      );

      int i2 = 0;
      final r2 = orch.decide(
        snapshot: s,
        nowUtc: DateTime.utc(2026, 1, 1),
        newId: () => 'id_${i2++}',
        emitTelemetry: false,
      );

      expect(r1.output.schemaVersion, OrchestratorOutputV1.schema);
      expect(r2.output.schemaVersion, OrchestratorOutputV1.schema);

      expect(r1.output.mainOptionId, r2.output.mainOptionId);
      expect(r1.output.alternativeOptionIds, r2.output.alternativeOptionIds);
      expect(r1.output.scoringConfigVersion, r2.output.scoringConfigVersion);
      expect(r1.output.inputsHash, r2.output.inputsHash);
      expect(r1.output.frameConfidence, r2.output.frameConfidence);
      expect(r1.output.telemetryEmittedCount, 0);
      expect(r2.output.telemetryEmittedCount, 0);
    });

    test('Validator accepts correct orchestrator output', () {
      final gen = PropertyGenerator(seed: 7777);
      final s = gen.generateValidSnapshot();

      final orch = TimeChoiceOrchestratorV1();

      final r = orch.decide(
        snapshot: s,
        nowUtc: DateTime.utc(2026, 1, 1),
        newId: () => 'id_0',
        emitTelemetry: false,
      );

      final res = OrchestratorOutputValidator.validate(r.output);
      expect(res.ok, isTrue, reason: 'errors: ${res.errors}');
    });

    test('Fallback mainOptionId is always non-empty and in frame options', () {
      final gen = PropertyGenerator(seed: 1313);
      final base = gen.generateValidSnapshot();

      final trace = base.frameOptions.scoringTrace;
      expect(trace, isNull, reason: 'Generator snapshots should not include trace by default.');

      final orch = TimeChoiceOrchestratorV1();

      final r = orch.decide(
        snapshot: base,
        nowUtc: DateTime.utc(2026, 1, 1),
        newId: () => 'id_0',
        emitTelemetry: false,
      );

      expect(r.output.mainOptionId, isNotEmpty);
      final ids = r.snapshotWithTrace.frameOptions.options.map((o) => o.optionId).toSet();
      expect(ids.contains(r.output.mainOptionId), isTrue);
    });

    test('Telemetry count only: emits 3..5 events and all envelopes validate', () {
      final gen = PropertyGenerator(seed: 2020);
      final s = gen.generateValidSnapshot();

      final orch = TimeChoiceOrchestratorV1();

      int i = 0;
      final r = orch.decide(
        snapshot: s,
        nowUtc: DateTime.utc(2026, 1, 1),
        newId: () => 'evt_${i++}',
        emitTelemetry: true,
        telemetrySource: TelemetrySource.orchestrator,
      );

      expect(r.output.telemetryEmittedCount, inInclusiveRange(3, 5));
      expect(r.events.length, r.output.telemetryEmittedCount);

      for (final e in r.events) {
        final env = TelemetryIdempotency.envelopeOf(e);
        final res = TelemetryValidator.validateEnvelope(env);
        expect(res.ok, isTrue, reason: 'errors: ${res.errors}');
      }
    });
  });
}
