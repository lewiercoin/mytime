import '../enums/option_effort.dart';
import '../enums/option_type.dart';

class MissionV1 {
  final String missionId;

  /// Mapuje 1:1 do FramedOption.type
  final OptionType type;

  /// Mapuje 1:1 do FramedOption.effort
  final OptionEffort effort;

  /// Mapuje 1:1 do FramedOption.timeCostMin
  final int timeCostMin;

  /// Mapuje 1:1 do WorldEffectPreview.dreamDelta (-1..1)
  final double dreamDelta;

  /// Opcjonalne (bez tekstu)
  final int? moneyDelta;

  MissionV1({
    required this.missionId,
    required this.type,
    required this.effort,
    required this.timeCostMin,
    required this.dreamDelta,
    required this.moneyDelta,
  });
}
