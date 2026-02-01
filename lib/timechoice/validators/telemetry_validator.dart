import '../dto/telemetry.dart';
import 'validator_result.dart';

class TelemetryValidator {
  static ValidatorResult validateEnvelope(TelemetryEnvelope e) {
    final errors = <String>[];
    if (e.eventId.isEmpty) errors.add('event_id empty');
    if (e.snapshotId.isEmpty) errors.add('snapshot_id empty');
    if (e.subjectRef.isEmpty) errors.add('subject_ref empty');
    if (e.schemaVersion.isEmpty) errors.add('schema_version empty');
    if (e.loopVersion.isEmpty) errors.add('loop_version empty');

    return errors.isEmpty ? ValidatorResult.ok() : ValidatorResult.fail(errors);
  }
}
