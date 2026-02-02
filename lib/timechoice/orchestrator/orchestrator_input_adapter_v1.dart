import '../dto/orchestrator_input_v1.dart';
import '../dto/time_choice_loop_snapshot.dart';
import '../enums/context_trigger.dart';
import '../enums/option_effort.dart';
import '../enums/option_type.dart';
import '../enums/eligibility_reason_code.dart';
import '../enums/preferred_duration_band.dart';
import '../enums/learning_updated_field.dart';

class OrchestratorInputAdapterV1 {
  static TimeChoiceLoopSnapshot toSnapshot({
    required OrchestratorInputV1 input,
    required String snapshotId,
    required String loopVersion,
  }) {
    final duration = input.timeRemainingMin.clamp(0, 240);
    final bufferRatio = _bufferRatioForTimeBlock(input.currentTimeBlock);

    final dreamPresent = input.activeGoalId != null;
    final salience = dreamPresent ? 0.7 : 0.0;

    final framedOptions = <FramedOption>[
      FramedOption(
        optionId: 'opt_default',
        type: OptionType.mission,
        effort: OptionEffort.low,
        timeCostMin: (duration * 0.5).round().clamp(0, 240),
        eligibility: Eligibility(
          isAllowedByParentFrame:
              !input.parentConstraints.blockedTypes.contains(OptionType.mission),
          fitsTimeWindow: true,
          hardBlockHit: false,
          reasonCodes: const <EligibilityReasonCode>[],
        ),
        worldEffectPreview: WorldEffectPreview(
          dreamDelta: dreamPresent ? 0.2 : 0.0,
          moneyDelta: null,
        ),
      ),
    ];

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
        level: input.coldStart ? 2 : 2,
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
        options: framedOptions,
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
        updatedFields: const <LearningUpdatedField>[],
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
