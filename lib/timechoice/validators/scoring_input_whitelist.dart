import '../enums/scoring_input_field.dart';
import 'validator_result.dart';

class ScoringInputWhitelist {
  static const Set<ScoringInputField> whitelist = {
    ScoringInputField.availableTimeWindowDurationMin,
    ScoringInputField.availableTimeWindowBufferRatio,
    ScoringInputField.availableTimeWindowHardBlocksCodes,
    ScoringInputField.energyStateLevel,
    ScoringInputField.energyStateSource,
    ScoringInputField.dreamIdPresent,
    ScoringInputField.dreamHorizon,
    ScoringInputField.dreamSalience,
    ScoringInputField.parentAllowedModes,
    ScoringInputField.parentBlockedTypes,
    ScoringInputField.parentIsNowInQuietHours,
  };

  static ValidatorResult validate(List<ScoringInputField> used) {
    final errors = <String>[];
    for (final f in used) {
      if (!whitelist.contains(f)) {
        errors.add('used_input_fields contains non-whitelisted field: $f');
      }
    }
    return errors.isEmpty ? ValidatorResult.ok() : ValidatorResult.fail(errors);
  }
}
