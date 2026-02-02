import '../enums/age_mode.dart';
import '../enums/surface.dart';
import '../enums/context_trigger.dart';

class OrchestratorOutputV1 {
  static const String schema = 'orchestrator/v1';

  final String schemaVersion;

  final String snapshotId;
  final String subjectRef;
  final String? familyRef;

  final AgeMode ageMode;
  final Surface surface;
  final ContextTrigger contextTrigger;

  /// Always non-null. If scoring produces no winner, we fall back to first
  /// optionId in snapshot.frameOptions.options.
  final String mainOptionId;

  /// 0..2 ids, no duplicates, never contains mainOptionId.
  final List<String> alternativeOptionIds;

  /// Final confidence materialized into snapshot by runner (C.6).
  final double frameConfidence;

  /// From ScoringTrace.scoringConfigVersion (e.g. "score/v1")
  final String scoringConfigVersion;

  /// From ScoringTrace.inputDigest.inputsHash
  final String inputsHash;

  /// Count only, 0..5.
  final int telemetryEmittedCount;

  OrchestratorOutputV1({
    this.schemaVersion = schema,
    required this.snapshotId,
    required this.subjectRef,
    this.familyRef,
    required this.ageMode,
    required this.surface,
    required this.contextTrigger,
    required this.mainOptionId,
    required List<String> alternativeOptionIds,
    required this.frameConfidence,
    required this.scoringConfigVersion,
    required this.inputsHash,
    required this.telemetryEmittedCount,
  }) : alternativeOptionIds = List.unmodifiable(alternativeOptionIds);
}
