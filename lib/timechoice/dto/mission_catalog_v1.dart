import 'mission_v1.dart';

class MissionCatalogV1 {
  static const String schema = 'mission_catalog/v1';

  final String schemaVersion;

  /// Katalog kandydatów "na teraz" (bez copy, bez opisów)
  final List<MissionV1> missions;

  MissionCatalogV1({
    this.schemaVersion = schema,
    required List<MissionV1> missions,
  }) : missions = List.unmodifiable(missions);
}
