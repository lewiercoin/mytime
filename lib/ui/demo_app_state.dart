import 'package:mytime/timechoice/timechoice.dart';

import 'demo_catalog.dart';

class DemoAppState {
  OrchestratorInputV1 input;
  MissionCatalogV1 catalog;

  /// Optional: store last output for quick UI display
  OrchestratorOutputV1? lastOutput;

  /// When user "chooses" a mission on Tasks screen, we can simulate it by
  /// moving it to the front of the catalog (still deterministic due to sorting in adapter).
  String? selectedMissionId;

  /// E.2A: explicit mission choice (for scoring override logic)
  String? chosenMissionId;

  DemoAppState({
    required this.input,
    required this.catalog,
    required this.lastOutput,
    required this.selectedMissionId,
    required this.chosenMissionId,
  });

  factory DemoAppState.initial() {
    return DemoAppState(
      input: OrchestratorInputV1(
        currentTimeUtc: DateTime.now().toUtc(),
        timeRemainingMin: 150,
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
      ),
      catalog: DemoCatalog.defaultCatalog(),
      lastOutput: null,
      selectedMissionId: null,
      chosenMissionId: null,
    );
  }

  void copyFrom(DemoAppState other) {
    input = other.input;
    catalog = other.catalog;
    lastOutput = other.lastOutput;
    selectedMissionId = other.selectedMissionId;
    chosenMissionId = other.chosenMissionId;
  }

  DemoAppState copyWith({
    OrchestratorInputV1? input,
    MissionCatalogV1? catalog,
    OrchestratorOutputV1? lastOutput,
    String? selectedMissionId,
    String? chosenMissionId,
  }) {
    return DemoAppState(
      input: input ?? this.input,
      catalog: catalog ?? this.catalog,
      lastOutput: lastOutput ?? this.lastOutput,
      selectedMissionId: selectedMissionId ?? this.selectedMissionId,
      chosenMissionId: chosenMissionId ?? this.chosenMissionId,
    );
  }
}
