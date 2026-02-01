import '../dto/scoring_trace.dart';
import 'validator_result.dart';
import 'scoring_input_whitelist.dart';

class ScoringTraceValidator {
  static ValidatorResult validate(ScoringTrace t, Set<String> optionIds) {
    final errors = <String>[];

    if (t.scoringTraceId.isEmpty) errors.add('scoring_trace_id empty');
    if (t.scoringConfigVersion.isEmpty) errors.add('scoring_config_version empty');
    if (t.snapshotId.isEmpty) errors.add('snapshot_id empty');
    if (t.candidatesCount != t.candidates.length) {
      errors.add('candidates_count mismatch');
    }

    if (!optionIds.contains(t.selectedTopOptionId)) {
      errors.add('selected_top_option_id must exist in frame options');
    }
    if (t.candidatesCount >= 2 && t.runnerUpOptionId == null) {
      errors.add('runner_up_option_id required when candidates_count >= 2');
    }
    if (t.candidatesCount == 1 && t.runnerUpOptionId != null) {
      errors.add('runner_up_option_id must be null when only one candidate');
    }

    final wl = ScoringInputWhitelist.validate(t.inputDigest.usedInputFields);
    if (!wl.ok) errors.addAll(wl.errors);

    for (final w in [t.weights.wTime, t.weights.wEnergy, t.weights.wDirection, t.weights.wFrame]) {
      if (w < 0.0 || w > 1.0) errors.add('weight out of 0..1');
    }

    return errors.isEmpty ? ValidatorResult.ok() : ValidatorResult.fail(errors);
  }
}
