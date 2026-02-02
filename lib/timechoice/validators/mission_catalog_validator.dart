import '../dto/mission_catalog_v1.dart';
import '../dto/mission_v1.dart';
import 'validator_result.dart';

class MissionCatalogValidator {
  static ValidatorResult validate(MissionCatalogV1 c) {
    final errors = <String>[];

    if (c.schemaVersion != MissionCatalogV1.schema) {
      errors.add('schema_version invalid');
    }

    if (c.missions.isEmpty) {
      errors.add('missions empty');
      return ValidatorResult.fail(errors);
    }

    final ids = <String>{};
    for (final MissionV1 m in c.missions) {
      if (m.missionId.isEmpty) errors.add('mission_id empty');
      if (ids.contains(m.missionId)) errors.add('mission_id duplicate: ${m.missionId}');
      ids.add(m.missionId);

      if (m.timeCostMin < 0) errors.add('time_cost_min negative: ${m.missionId}');
      if (m.timeCostMin > 240) errors.add('time_cost_min too large: ${m.missionId}');

      if (m.dreamDelta < -1.0 || m.dreamDelta > 1.0) {
        errors.add('dream_delta out of range: ${m.missionId}');
      }
    }

    return errors.isEmpty ? ValidatorResult.ok() : ValidatorResult.fail(errors);
  }
}
