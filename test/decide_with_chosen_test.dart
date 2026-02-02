import 'package:flutter_test/flutter_test.dart';
import 'package:mytime/timechoice/timechoice.dart';
import 'package:mytime/ui/core_decision_runner.dart';
import 'package:mytime/ui/demo_catalog.dart';

void main() {
  group('E.2B decideWithChosen', () {
    test('chosen mission becomes main option', () {
      final input = OrchestratorInputV1(
        currentTimeUtc: DateTime.utc(2026, 1, 1),
        timeRemainingMin: 120,
        currentTimeBlock: TimeBlockV1.free,
        childId: 'child_demo',
        ageMode: AgeMode.junior,
        surface: Surface.today,
        activeGoalId: 'goal_bike',
        progressToGoal: 0.3,
        coldStart: true,
        parentConstraints: ParentConstraintsV1(
          blockedTypes: const [],
          isNowInQuietHours: false,
        ),
      );

      final catalog = DemoCatalog.defaultCatalog();

      // Choose a specific mission
      const chosenId = 'm_quick_reset_10';
      final out = CoreDecisionRunner.decideWithChosen(
        input: input,
        catalog: catalog,
        chosenMissionId: chosenId,
      );

      // Validate output
      final res = OrchestratorOutputValidator.validate(out);
      expect(res.ok, isTrue, reason: 'errors: ${res.errors}');
    });

    test('decideWithChosen produces valid output for any mission in catalog',
        () {
      final input = OrchestratorInputV1(
        currentTimeUtc: DateTime.utc(2026, 1, 1),
        timeRemainingMin: 240, // Increased to accommodate all missions
        currentTimeBlock: TimeBlockV1.free,
        childId: 'child_demo',
        ageMode: AgeMode.junior,
        surface: Surface.today,
        activeGoalId: 'goal_bike',
        progressToGoal: 0.3,
        coldStart: true,
        parentConstraints: ParentConstraintsV1(
          blockedTypes: const [],
          isNowInQuietHours: false,
        ),
      );

      final catalog = DemoCatalog.defaultCatalog();

      // Test choosing each mission - output should be valid
      for (final mission in catalog.missions) {
        final out = CoreDecisionRunner.decideWithChosen(
          input: input,
          catalog: catalog,
          chosenMissionId: mission.missionId,
        );

        final res = OrchestratorOutputValidator.validate(out);
        expect(res.ok, isTrue,
            reason:
                'Validation failed for mission ${mission.missionId}: ${res.errors}');
      }
    });
  });
}
