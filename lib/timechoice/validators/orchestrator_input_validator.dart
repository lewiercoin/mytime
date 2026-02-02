import '../dto/orchestrator_input_v1.dart';
import 'validator_result.dart';

class OrchestratorInputValidator {
  static ValidatorResult validate(OrchestratorInputV1 i) {
    final errors = <String>[];

    if (i.schemaVersion != OrchestratorInputV1.schema) {
      errors.add('schema_version invalid');
    }

    if (i.childId.isEmpty) errors.add('child_id empty');

    if (i.timeRemainingMin < 0) errors.add('time_remaining_min negative');
    if (i.timeRemainingMin > 24 * 60) errors.add('time_remaining_min too large');

    if (i.progressToGoal < 0.0 || i.progressToGoal > 1.0) {
      errors.add('progress_to_goal out of range');
    }

    if (i.activeGoalId == null) {
      if (i.progressToGoal != 0.0) {
        errors.add('progress_to_goal must be 0 when active_goal_id is null');
      }
    }

    final bt = i.parentConstraints.blockedTypes;
    if (bt.toSet().length != bt.length) {
      errors.add('parent_constraints.blocked_types contains duplicates');
    }

    return errors.isEmpty ? ValidatorResult.ok() : ValidatorResult.fail(errors);
  }
}
