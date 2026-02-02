import '../enums/age_mode.dart';
import '../enums/surface.dart';
import '../scoring/config/score_config_v1.dart';
import 'validator_result.dart';

class ScoreConfigValidator {
  static ValidatorResult validateV1() {
    final errors = <String>[];

    for (final age in AgeMode.values) {
      for (final surface in Surface.values) {
        final w = ScoreConfigV1.weightsFor(age, surface);
        final sum = w.wTime + w.wEnergy + w.wDirection + w.wFrame;
        if ((sum - 1.0).abs() > 0.0001) {
          errors.add('weights sum != 1.0 for ${ScoreConfigV1.profileId(age, surface)}');
        }
        if ((w.wFrame - 0.05).abs() > 0.0001) {
          errors.add('w_frame != 0.05 for ${ScoreConfigV1.profileId(age, surface)}');
        }
      }
    }

    for (final surface in Surface.values) {
      final wm = ScoreConfigV1.weightsFor(AgeMode.mini, surface);
      final wj = ScoreConfigV1.weightsFor(AgeMode.junior, surface);
      final wp = ScoreConfigV1.weightsFor(AgeMode.pro, surface);

      if (!(wm.wDirection <= wj.wDirection && wj.wDirection <= wp.wDirection)) {
        errors.add('w_direction monotonic violated for surface=${surface.name}');
      }
      if (!(wm.wTime >= wj.wTime && wj.wTime >= wp.wTime)) {
        errors.add('w_time monotonic violated for surface=${surface.name}');
      }
    }

    if (ScoreV1Constants.effortToleranceForEnergyLevel(1) != 1) errors.add('effort_tolerance[1]!=1');
    if (ScoreV1Constants.effortToleranceForEnergyLevel(2) != 2) errors.add('effort_tolerance[2]!=2');
    if (ScoreV1Constants.effortToleranceForEnergyLevel(3) != 3) errors.add('effort_tolerance[3]!=3');

    if ((ScoreV1Constants.defaultSingleCandidateConf - 0.50).abs() > 0.0001) {
      errors.add('default_single_candidate_conf != 0.50');
    }

    return errors.isEmpty ? ValidatorResult.ok() : ValidatorResult.fail(errors);
  }
}
