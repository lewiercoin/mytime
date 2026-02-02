import '../enums/age_mode.dart';
import '../enums/surface.dart';
import '../enums/option_type.dart';
import '../enums/time_block_v1.dart';

class ParentConstraintsV1 {
  final List<OptionType> blockedTypes;
  final bool isNowInQuietHours;

  ParentConstraintsV1({
    required this.blockedTypes,
    required this.isNowInQuietHours,
  });
}

class OrchestratorInputV1 {
  static const String schema = 'orchestrator_input/v1';

  final String schemaVersion;

  final DateTime currentTimeUtc;
  final int timeRemainingMin;
  final TimeBlockV1 currentTimeBlock;

  final String childId;
  final AgeMode ageMode;

  final Surface surface;

  final String? activeGoalId;
  final double progressToGoal;

  final bool coldStart;

  final ParentConstraintsV1 parentConstraints;

  OrchestratorInputV1({
    this.schemaVersion = schema,
    required this.currentTimeUtc,
    required this.timeRemainingMin,
    required this.currentTimeBlock,
    required this.childId,
    required this.ageMode,
    required this.surface,
    required this.activeGoalId,
    required this.progressToGoal,
    required this.coldStart,
    required this.parentConstraints,
  });
}
