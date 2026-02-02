import 'package:flutter_test/flutter_test.dart';
import 'package:mytime/timechoice/timechoice.dart';
import 'package:mytime/ui/core_decision_runner.dart';
import 'package:mytime/ui/demo_catalog.dart';

void main() {
  group('E.3A done flow contract', () {
    test('decideAfterDone returns valid orchestrator output', () {
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
      final out = CoreDecisionRunner.decideAfterDone(
        input: input,
        catalog: catalog,
        missionId: catalog.missions.first.missionId,
        actualTimeSpentMin: 15,
        outcome: WorldOutcome.completed,
      );

      final res = OrchestratorOutputValidator.validate(out);
      expect(res.ok, isTrue, reason: 'errors: ${res.errors}');
      expect(out.mainOptionId, isNotEmpty);
    });
  });
}
