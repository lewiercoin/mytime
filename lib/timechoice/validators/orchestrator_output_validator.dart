import '../dto/orchestrator_output_v1.dart';
import 'validator_result.dart';

class OrchestratorOutputValidator {
  static ValidatorResult validate(OrchestratorOutputV1 o) {
    final errors = <String>[];

    if (o.schemaVersion != OrchestratorOutputV1.schema) {
      errors.add('schema_version invalid');
    }

    if (o.snapshotId.isEmpty) errors.add('snapshot_id empty');
    if (o.subjectRef.isEmpty) errors.add('subject_ref empty');

    if (o.mainOptionId.isEmpty) errors.add('main_option_id empty');

    if (o.alternativeOptionIds.length > 2) {
      errors.add('alternative_option_ids too many');
    }

    final altSet = o.alternativeOptionIds.toSet();
    if (altSet.length != o.alternativeOptionIds.length) {
      errors.add('alternative_option_ids contain duplicates');
    }

    if (o.alternativeOptionIds.contains(o.mainOptionId)) {
      errors.add('alternative_option_ids contains main_option_id');
    }

    if (o.frameConfidence < 0.0 || o.frameConfidence > 1.0) {
      errors.add('frame_confidence out of range');
    }

    if (o.scoringConfigVersion.isEmpty) errors.add('scoring_config_version empty');
    if (o.inputsHash.isEmpty) errors.add('inputs_hash empty');

    if (o.telemetryEmittedCount < 0 || o.telemetryEmittedCount > 5) {
      errors.add('telemetry_emitted_count out of range');
    }

    return errors.isEmpty ? ValidatorResult.ok() : ValidatorResult.fail(errors);
  }
}
