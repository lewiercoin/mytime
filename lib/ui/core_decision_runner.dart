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
}
