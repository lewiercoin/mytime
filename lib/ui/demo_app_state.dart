import 'package:mytime/timechoice/timechoice.dart';

import 'demo_catalog.dart';

/// E.4B: proste stany akceptacji rodzica (in-memory only)
enum ParentApprovalState {
  pending,
  approved,
  rejected,
}

class CompletedMissionRecord {
  final String missionId;
  final DateTime completedAtUtc;

  /// Jak długo realnie zajęło (z panelu "ZROBIONE!")
  final int actualTimeSpentMin;

  /// completed/partial/abandoned
  final WorldOutcome outcome;

  /// Nowe w E.4B
  final ParentApprovalState approvalState;

  CompletedMissionRecord({
    required this.missionId,
    required this.completedAtUtc,
    required this.actualTimeSpentMin,
    required this.outcome,
    required this.approvalState,
  });

  CompletedMissionRecord copyWith({
    String? missionId,
    DateTime? completedAtUtc,
    int? actualTimeSpentMin,
    WorldOutcome? outcome,
    ParentApprovalState? approvalState,
  }) {
    return CompletedMissionRecord(
      missionId: missionId ?? this.missionId,
      completedAtUtc: completedAtUtc ?? this.completedAtUtc,
      actualTimeSpentMin: actualTimeSpentMin ?? this.actualTimeSpentMin,
      outcome: outcome ?? this.outcome,
      approvalState: approvalState ?? this.approvalState,
    );
  }
}

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

  // E.3A: in-memory history of outcomes (no persistence)
  List<CompletedMissionRecord> completed;

  DemoAppState({
    required this.input,
    required this.catalog,
    required this.lastOutput,
    required this.selectedMissionId,
    required this.chosenMissionId,
    required this.completed,
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
      completed: const [],
    );
  }

  void copyFrom(DemoAppState other) {
    input = other.input;
    catalog = other.catalog;
    lastOutput = other.lastOutput;
    selectedMissionId = other.selectedMissionId;
    chosenMissionId = other.chosenMissionId;
    completed = other.completed;
  }

  DemoAppState copyWith({
    OrchestratorInputV1? input,
    MissionCatalogV1? catalog,
    OrchestratorOutputV1? lastOutput,
    String? selectedMissionId,
    String? chosenMissionId,
    List<CompletedMissionRecord>? completed,
  }) {
    return DemoAppState(
      input: input ?? this.input,
      catalog: catalog ?? this.catalog,
      lastOutput: lastOutput ?? this.lastOutput,
      selectedMissionId: selectedMissionId ?? this.selectedMissionId,
      chosenMissionId: chosenMissionId ?? this.chosenMissionId,
      completed: completed ?? this.completed,
    );
  }

  /// E.4B: get pending approvals
  List<CompletedMissionRecord> get pendingApprovals => completed
      .where((r) => r.approvalState == ParentApprovalState.pending)
      .toList();

  /// E.4B: get approved missions
  List<CompletedMissionRecord> get approved => completed
      .where((r) => r.approvalState == ParentApprovalState.approved)
      .toList();

  /// E.4B: get rejected missions
  List<CompletedMissionRecord> get rejected => completed
      .where((r) => r.approvalState == ParentApprovalState.rejected)
      .toList();
}
