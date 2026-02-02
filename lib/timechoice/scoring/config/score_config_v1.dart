import '../../enums/age_mode.dart';
import '../../enums/surface.dart';
import '../../dto/scoring_trace.dart';

class ScoreV1Constants {
  static const String scoringConfigVersion = 'score/v1';

  static int effortToleranceForEnergyLevel(int energyLevel) {
    switch (energyLevel) {
      case 1:
        return 1;
      case 2:
        return 2;
      case 3:
        return 3;
      default:
        return 1;
    }
  }

  static const double gapLow = 0.05;
  static const double gapHigh = 0.25;
  static const double confMin = 0.40;
  static const double confMax = 0.95;
  static const double defaultSingleCandidateConf = 0.50;
}

class ScoreV1Profile {
  final String configProfileId;
  final Weights weights;

  const ScoreV1Profile({
    required this.configProfileId,
    required this.weights,
  });
}

class ScoreConfigV1 {
  static String profileId(AgeMode ageMode, Surface surface) {
    final a = ageMode.name;
    final s = _surfaceId(surface);
    return '$a.$s.v1';
  }

  static String _surfaceId(Surface s) {
    switch (s) {
      case Surface.today:
        return 'today';
      case Surface.plan:
        return 'plan';
      case Surface.dream:
        return 'dream';
      case Surface.piggyOverlay:
        return 'piggy_overlay';
    }
  }

  static Weights weightsFor(AgeMode ageMode, Surface surface) {
    final pid = profileId(ageMode, surface);

    if (pid == 'mini.today.v1') {
      return Weights(
          wTime: 0.55, wEnergy: 0.35, wDirection: 0.05, wFrame: 0.05);
    }
    if (pid == 'mini.plan.v1') {
      return Weights(
          wTime: 0.50, wEnergy: 0.35, wDirection: 0.10, wFrame: 0.05);
    }
    if (pid == 'mini.dream.v1') {
      return Weights(
          wTime: 0.45, wEnergy: 0.35, wDirection: 0.15, wFrame: 0.05);
    }
    if (pid == 'mini.piggy_overlay.v1') {
      return Weights(
          wTime: 0.60, wEnergy: 0.30, wDirection: 0.05, wFrame: 0.05);
    }

    if (pid == 'junior.today.v1') {
      return Weights(
          wTime: 0.45, wEnergy: 0.35, wDirection: 0.15, wFrame: 0.05);
    }
    if (pid == 'junior.plan.v1') {
      return Weights(
          wTime: 0.40, wEnergy: 0.30, wDirection: 0.25, wFrame: 0.05);
    }
    if (pid == 'junior.dream.v1') {
      return Weights(
          wTime: 0.35, wEnergy: 0.30, wDirection: 0.30, wFrame: 0.05);
    }
    if (pid == 'junior.piggy_overlay.v1') {
      return Weights(
          wTime: 0.50, wEnergy: 0.35, wDirection: 0.10, wFrame: 0.05);
    }

    if (pid == 'pro.today.v1') {
      return Weights(
          wTime: 0.35, wEnergy: 0.30, wDirection: 0.30, wFrame: 0.05);
    }
    if (pid == 'pro.plan.v1') {
      return Weights(
          wTime: 0.30, wEnergy: 0.25, wDirection: 0.40, wFrame: 0.05);
    }
    if (pid == 'pro.dream.v1') {
      return Weights(
          wTime: 0.25, wEnergy: 0.25, wDirection: 0.45, wFrame: 0.05);
    }
    if (pid == 'pro.piggy_overlay.v1') {
      return Weights(
          wTime: 0.40, wEnergy: 0.30, wDirection: 0.25, wFrame: 0.05);
    }

    return Weights(wTime: 0.45, wEnergy: 0.35, wDirection: 0.15, wFrame: 0.05);
  }
}
