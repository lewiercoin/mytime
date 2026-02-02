import 'package:flutter_test/flutter_test.dart';
import 'package:mytime/timechoice/timechoice.dart';

void main() {
  group('D.3B mission catalog (v1) -> snapshot options mapping', () {
    test('Catalog validator accepts correct catalog', () {
      final c = MissionCatalogV1(
        missions: [
          MissionV1(
            missionId: 'm_1',
            type: OptionType.mission,
            effort: OptionEffort.low,
            timeCostMin: 15,
            dreamDelta: 0.2,
            moneyDelta: null,
          ),
          MissionV1(
            missionId: 'm_2',
            type: OptionType.rest,
            effort: OptionEffort.low,
            timeCostMin: 10,
            dreamDelta: -0.1,
            moneyDelta: null,
          ),
        ],
      );

      final res = MissionCatalogValidator.validate(c);
      expect(res.ok, isTrue, reason: 'errors: ${res.errors}');
    });

    test('Adapter produces options equal to catalog size (and sorted by id)', () {
      final input = OrchestratorInputV1(
        currentTimeUtc: DateTime.utc(2026, 1, 1),
        timeRemainingMin: 60,
        currentTimeBlock: TimeBlockV1.free,
        childId: 'child_1',
        ageMode: AgeMode.junior,
        surface: Surface.today,
        activeGoalId: 'goal_1',
        progressToGoal: 0.1,
        coldStart: true,
        parentConstraints: ParentConstraintsV1(
          blockedTypes: const [],
          isNowInQuietHours: false,
        ),
      );

      final catalog = MissionCatalogV1(
        missions: [
          MissionV1(
            missionId: 'b',
            type: OptionType.mission,
            effort: OptionEffort.medium,
            timeCostMin: 20,
            dreamDelta: 0.3,
            moneyDelta: null,
          ),
          MissionV1(
            missionId: 'a',
            type: OptionType.rest,
            effort: OptionEffort.low,
            timeCostMin: 10,
            dreamDelta: 0.0,
            moneyDelta: null,
          ),
        ],
      );

      final snap = OrchestratorCatalogAdapterV1.toSnapshot(
        input: input,
        catalog: catalog,
        snapshotId: 'snap_1',
        loopVersion: 'timechoice/v1',
      );

      expect(snap.frameOptions.options.length, 2);
      expect(snap.frameOptions.options[0].optionId, 'a');
      expect(snap.frameOptions.options[1].optionId, 'b');
    });

    test('Eligibility flags: blocked types and time overflow are reflected', () {
      final input = OrchestratorInputV1(
        currentTimeUtc: DateTime.utc(2026, 1, 1),
        timeRemainingMin: 10,
        currentTimeBlock: TimeBlockV1.free,
        childId: 'child_1',
        ageMode: AgeMode.junior,
        surface: Surface.today,
        activeGoalId: null,
        progressToGoal: 0.0,
        coldStart: false,
        parentConstraints: ParentConstraintsV1(
          blockedTypes: const [OptionType.mission],
          isNowInQuietHours: false,
        ),
      );

      final catalog = MissionCatalogV1(
        missions: [
          MissionV1(
            missionId: 'm_blocked',
            type: OptionType.mission,
            effort: OptionEffort.low,
            timeCostMin: 5,
            dreamDelta: 0.5,
            moneyDelta: null,
          ),
          MissionV1(
            missionId: 'm_overflow',
            type: OptionType.rest,
            effort: OptionEffort.low,
            timeCostMin: 240,
            dreamDelta: 0.0,
            moneyDelta: null,
          ),
        ],
      );

      final snap = OrchestratorCatalogAdapterV1.toSnapshot(
        input: input,
        catalog: catalog,
        snapshotId: 'snap_2',
        loopVersion: 'timechoice/v1',
      );

      final blocked = snap.frameOptions.options.firstWhere((o) => o.optionId == 'm_blocked');
      expect(blocked.eligibility.isAllowedByParentFrame, isFalse);
      expect(blocked.eligibility.reasonCodes, contains(EligibilityReasonCode.blockedByParent));

      final overflow = snap.frameOptions.options.firstWhere((o) => o.optionId == 'm_overflow');
      expect(overflow.eligibility.fitsTimeWindow, isFalse);
      expect(overflow.eligibility.reasonCodes, contains(EligibilityReasonCode.timeOverflow));
    });

    test('Integration: Input+Catalog -> Snapshot -> D.1 output contract validates', () {
      final input = OrchestratorInputV1(
        currentTimeUtc: DateTime.utc(2026, 1, 1),
        timeRemainingMin: 60,
        currentTimeBlock: TimeBlockV1.free,
        childId: 'child_1',
        ageMode: AgeMode.junior,
        surface: Surface.today,
        activeGoalId: 'goal_1',
        progressToGoal: 0.2,
        coldStart: true,
        parentConstraints: ParentConstraintsV1(
          blockedTypes: const [],
          isNowInQuietHours: false,
        ),
      );

      final catalog = MissionCatalogV1(
        missions: [
          MissionV1(
            missionId: 'm_1',
            type: OptionType.mission,
            effort: OptionEffort.low,
            timeCostMin: 15,
            dreamDelta: 0.2,
            moneyDelta: null,
          ),
          MissionV1(
            missionId: 'm_2',
            type: OptionType.rest,
            effort: OptionEffort.low,
            timeCostMin: 10,
            dreamDelta: 0.0,
            moneyDelta: null,
          ),
        ],
      );

      final snap = OrchestratorCatalogAdapterV1.toSnapshot(
        input: input,
        catalog: catalog,
        snapshotId: 'snap_3',
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
