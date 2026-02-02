import '../dto/mission_catalog_v1.dart';
import '../dto/orchestrator_input_v1.dart';
import '../dto/time_choice_loop_snapshot.dart';
import '../enums/context_trigger.dart';
import '../enums/eligibility_reason_code.dart';
import '../enums/preferred_duration_band.dart';
import '../enums/time_block_v1.dart';

class OrchestratorCatalogAdapterV1 {
  static TimeChoiceLoopSnapshot toSnapshot({
    required OrchestratorInputV1 input,
    required MissionCatalogV1 catalog,
    required String snapshotId,
    required String loopVersion,
  }) {
    final duration = input.timeRemainingMin.clamp(0, 240);
    final bufferRatio = _bufferRatioForTimeBlock(input.currentTimeBlock);
    final effectiveMin = duration * (1.0 - bufferRatio);

    final dreamPresent = input.activeGoalId != null;
    final salience = dreamPresent ? 0.7 : 0.0;

    final options = <FramedOption>[];
    for (final m in catalog.missions) {
      final blocked = input.parentConstraints.blockedTypes.contains(m.type);

      final fits = m.timeCostMin.toDouble() <= effectiveMin;

      final reasonCodes = <EligibilityReasonCode>[];
      if (blocked) reasonCodes.add(EligibilityReasonCode.blockedByParent);
      if (!fits) reasonCodes.add(EligibilityReasonCode.timeOverflow);

      options.add(
        FramedOption(
          optionId: m.missionId,
          type: m.type,
          effort: m.effort,
          timeCostMin: m.timeCostMin,
          eligibility: Eligibility(
            isAllowedByParentFrame: !blocked,
            fitsTimeWindow: fits,
            hardBlockHit: false,
            reasonCodes: reasonCodes,
          ),
          worldEffectPreview: WorldEffectPreview(
            dreamDelta: dreamPresent ? m.dreamDelta : 0.0,
            moneyDelta: m.moneyDelta,
          ),
        ),
      );
    }

    options.sort((a, b) => a.optionId.compareTo(b.optionId));

    return TimeChoiceLoopSnapshot(
      snapshotId: snapshotId,
      timestampUtc: input.currentTimeUtc,
      loopVersion: loopVersion,
      ageMode: input.ageMode,
      surface: input.surface,
      contextTrigger: ContextTrigger.generic,
      subjectRef: input.childId,
      familyRef: null,
      availableTimeWindow: AvailableTimeWindow(
        durationMin: duration,
        bufferRatio: bufferRatio,
        constraints: TimeConstraints(hardBlocksCodes: const []),
      ),
      energyState: EnergyState(
        level: 2,
        source: EnergySource.inferred,
        confidence: 0.7,
      ),
      dreamAnchor: DreamAnchor(
        dreamId: input.activeGoalId,
        horizon: DreamHorizon.weeks,
        salience: salience,
        progress: DreamProgress(value: input.progressToGoal.clamp(0.0, 1.0)),
      ),
      parentFrame: ParentFrame(
        allowedMode: AllowedMode.mixed,
        blockedTypes: input.parentConstraints.blockedTypes,
        isNowInQuietHours: input.parentConstraints.isNowInQuietHours,
      ),
      frameOptions: FrameOptions(
        options: options,
        frameConfidence: 0.5,
        frameRationale: FrameRationale(
          childReason: const [],
          parentReasonPresent: false,
        ),
        scoringTrace: null,
      ),
      chosenOption: null,
      worldResponse: null,
      reflection: null,
      learningUpdate: LearningUpdate(
        parameterDeltasPresent: false,
        updatedFields: const [],
        preferredDurationBand: PreferredDurationBand.b20_40,
        nextFrameHintPresent: false,
        nextFrameHint: null,
      ),
    );
  }

  static double _bufferRatioForTimeBlock(TimeBlockV1 b) {
    switch (b) {
      case TimeBlockV1.school:
        return 0.2;
      case TimeBlockV1.family:
        return 0.2;
      case TimeBlockV1.sleep:
        return 0.3;
      case TimeBlockV1.free:
        return 0.1;
    }
  }
}
