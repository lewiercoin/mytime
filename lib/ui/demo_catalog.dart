import 'package:mytime/timechoice/timechoice.dart';

class DemoCatalog {
  static MissionCatalogV1 defaultCatalog() {
    return MissionCatalogV1(
      missions: [
        MissionV1(
          missionId: 'm_clean_room_30',
          type: OptionType.mission,
          effort: OptionEffort.medium,
          timeCostMin: 30,
          dreamDelta: 0.4,
          moneyDelta: 5,
        ),
        MissionV1(
          missionId: 'm_homework_45',
          type: OptionType.mission,
          effort: OptionEffort.high,
          timeCostMin: 45,
          dreamDelta: 0.3,
          moneyDelta: null,
        ),
        MissionV1(
          missionId: 'm_quick_reset_10',
          type: OptionType.rest,
          effort: OptionEffort.low,
          timeCostMin: 10,
          dreamDelta: 0.0,
          moneyDelta: null,
        ),
        MissionV1(
          missionId: 'm_walk_20',
          type: OptionType.mission,
          effort: OptionEffort.low,
          timeCostMin: 20,
          dreamDelta: 0.2,
          moneyDelta: null,
        ),
        MissionV1(
          missionId: 'm_screen_30',
          type: OptionType.rest,
          effort: OptionEffort.low,
          timeCostMin: 30,
          dreamDelta: -0.2,
          moneyDelta: null,
        ),
      ],
    );
  }

  static MissionCatalogV1 withSelectedFirst(
    MissionCatalogV1 base,
    String selectedId,
  ) {
    final list = [...base.missions];
    list.sort((a, b) => a.missionId.compareTo(b.missionId));

    final idx = list.indexWhere((m) => m.missionId == selectedId);
    if (idx <= 0) return MissionCatalogV1(missions: list);

    final chosen = list.removeAt(idx);
    list.insert(0, chosen);
    return MissionCatalogV1(missions: list);
  }
}
