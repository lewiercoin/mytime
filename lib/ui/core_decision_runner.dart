import 'package:mytime/timechoice/timechoice.dart';

class CoreDecisionRunner {
  static OrchestratorOutputV1 decide({
    required OrchestratorInputV1 input,
    required MissionCatalogV1 catalog,
  }) {
    // Ensure catalog contract is respected (defensive, still deterministic).
    final catRes = MissionCatalogValidator.validate(catalog);
    if (!catRes.ok) {
      throw StateError('Invalid mission catalog: ${catRes.errors}');
    }

    final inRes = OrchestratorInputValidator.validate(input);
    if (!inRes.ok) {
      throw StateError('Invalid orchestrator input: ${inRes.errors}');
    }

    final snap = OrchestratorCatalogAdapterV1.toSnapshot(
      input: input,
      catalog: catalog,
      snapshotId: 'snap_ui',
      loopVersion: 'timechoice/v1',
    );

    final orch = TimeChoiceOrchestratorV1();
    final result = orch.decide(
      snapshot: snap,
      nowUtc: DateTime.now().toUtc(),
      newId: () => 'evt_ui',
      emitTelemetry: false,
    );

    final outRes = OrchestratorOutputValidator.validate(result.output);
    if (!outRes.ok) {
      throw StateError('Invalid orchestrator output: ${outRes.errors}');
    }

    return result.output;
  }

  /// E.2B: Decide with explicit mission choice by modifying catalog
  static OrchestratorOutputV1 decideWithChosen({
    required OrchestratorInputV1 input,
    required MissionCatalogV1 catalog,
    required String chosenMissionId,
  }) {
    // Move chosen mission to front of catalog (deterministic priority)
    final updatedCatalog = _moveMissionToFront(catalog, chosenMissionId);

    // Run normal decision pipeline - output comes from orchestrator, not manually created
    return decide(input: input, catalog: updatedCatalog);
  }

  static MissionCatalogV1 _moveMissionToFront(
      MissionCatalogV1 catalog, String missionId) {
    final list = [...catalog.missions];
    final idx = list.indexWhere((m) => m.missionId == missionId);
    if (idx <= 0) return catalog;

    final chosen = list.removeAt(idx);
    list.insert(0, chosen);
    return MissionCatalogV1(missions: list);
  }
}
