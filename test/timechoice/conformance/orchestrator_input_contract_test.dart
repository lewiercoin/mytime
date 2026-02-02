import 'package:flutter_test/flutter_test.dart';
import 'package:mytime/timechoice/timechoice.dart';

void main() {
  group('D.2A orchestrator input contract (v1) -> snapshot mapping', () {
    test('Input validator accepts a correct minimal input', () {
      final input = OrchestratorInputV1(
        currentTimeUtc: DateTime.utc(2026, 1, 1),
        timeRemainingMin: 90,
        currentTimeBlock: TimeBlockV1.free,
        childId: 'child_1',
        ageMode: AgeMode.junior,
        surface: Surface.today,
        activeGoalId: null,
        progressToGoal: 0.0,
        coldStart: true,
        parentConstraints: ParentConstraintsV1(
          blockedTypes: const [],
          isNowInQuietHours: false,
        ),
      );

      final res = OrchestratorInputValidator.validate(input);
      expect(res.ok, isTrue, reason: 'errors: ${res.errors}');
    });

    test('Input validator rejects progress when goal is null', () {
      final input = OrchestratorInputV1(
        currentTimeUtc: DateTime.utc(2026, 1, 1),
        timeRemainingMin: 90,
        currentTimeBlock: TimeBlockV1.free,
        childId: 'child_1',
        ageMode: AgeMode.junior,
        surface: Surface.today,
        activeGoalId: null,
        progressToGoal: 0.2,
        coldStart: true,
        parentConstraints: ParentConstraintsV1(
          blockedTypes: const [],
          isNowInQuietHours: false,
        ),
      );

      final res = OrchestratorInputValidator.validate(input);
      expect(res.ok, isFalse);
    });

    test('Adapter mapping: key fields are mapped 1:1 into snapshot', () {
      final input = OrchestratorInputV1(
        currentTimeUtc: DateTime.utc(2026, 1, 1, 12),
        timeRemainingMin: 120,
        currentTimeBlock: TimeBlockV1.free,
        childId: 'child_abc',
        ageMode: AgeMode.pro,
        surface: Surface.plan,
        activeGoalId: 'goal_bike',
        progressToGoal: 0.4,
        coldStart: false,
        parentConstraints: ParentConstraintsV1(
          blockedTypes: const [OptionType.rest],
          isNowInQuietHours: true,
        ),
      );

      final snap = OrchestratorInputAdapterV1.toSnapshot(
        input: input,
        snapshotId: 'snap_1',
        loopVersion: 'timechoice/v1',
      );

      expect(snap.subjectRef, 'child_abc');
      expect(snap.timestampUtc, DateTime.utc(2026, 1, 1, 12));
      expect(snap.ageMode, AgeMode.pro);
      expect(snap.surface, Surface.plan);

      expect(snap.availableTimeWindow.durationMin, 120);
      expect(snap.parentFrame.blockedTypes, contains(OptionType.rest));
      expect(snap.parentFrame.isNowInQuietHours, isTrue);

      expect(snap.dreamAnchor.dreamId, 'goal_bike');
      expect(snap.dreamAnchor.progress.value, closeTo(0.4, 1e-9));
    });

    test('Integration: mapped snapshot can be fed into D.1 orchestrator', () {
      final input = OrchestratorInputV1(
        currentTimeUtc: DateTime.utc(2026, 1, 1),
        timeRemainingMin: 60,
        currentTimeBlock: TimeBlockV1.free,
        childId: 'child_1',
        ageMode: AgeMode.junior,
        surface: Surface.today,
        activeGoalId: null,
        progressToGoal: 0.0,
        coldStart: true,
        parentConstraints: ParentConstraintsV1(
          blockedTypes: const [],
          isNowInQuietHours: false,
        ),
      );

      final snap = OrchestratorInputAdapterV1.toSnapshot(
        input: input,
        snapshotId: 'snap_2',
        loopVersion: 'timechoice/v1',
      );

      final orch = TimeChoiceOrchestratorV1();
      final r = orch.decide(
        snapshot: snap,
        nowUtc: DateTime.utc(2026, 1, 1),
        newId: () => 'evt_0',
        emitTelemetry: false,
      );

      final outRes = OrchestratorOutputValidator.validate(r.output);
      expect(outRes.ok, isTrue, reason: 'errors: ${outRes.errors}');
    });
  });
}
