import '../dto/time_choice_loop_snapshot.dart';
import '../enums/age_mode.dart';
import '../enums/world_outcome.dart';
import '../enums/response_format.dart';
import '../enums/learning_updated_field.dart';
import 'validator_result.dart';
import 'judgement_lint.dart';

class SnapshotValidator {
  static ValidatorResult validate(TimeChoiceLoopSnapshot s) {
    final errors = <String>[];

    if (s.snapshotId.isEmpty) errors.add('snapshot_id is empty');
    if (s.timestampUtc.isAfter(DateTime.now().toUtc())) {
      errors.add('timestamp_utc is in the future');
    }
    if (s.loopVersion.isEmpty) errors.add('loop_version is empty');

    if (s.availableTimeWindow.durationMin < 5 ||
        s.availableTimeWindow.durationMin > 240) {
      errors.add('duration_min out of [5,240]');
    }
    if (s.availableTimeWindow.bufferRatio < 0.0 ||
        s.availableTimeWindow.bufferRatio > 0.5) {
      errors.add('buffer_ratio out of [0.0,0.5]');
    }
    if (s.availableTimeWindow.effectiveMin <= 0) {
      errors.add('effective_min must be > 0');
    }

    if (s.energyState.level < 1 || s.energyState.level > 3) {
      errors.add('energy_state.level must be 1..3');
    }
    if (s.energyState.confidence < 0.0 || s.energyState.confidence > 1.0) {
      errors.add('energy_state.confidence must be 0..1');
    }
    if (s.energyState.source == EnergySource.inferred &&
        s.energyState.confidence > 0.8) {
      errors.add('inferred energy confidence must be <= 0.8');
    }

    if (s.dreamAnchor.dreamId == null) {
      if (s.dreamAnchor.salience != 0.0) {
        errors.add('dream_id null => salience must be 0');
      }
    }
    if (s.dreamAnchor.salience < 0.0 || s.dreamAnchor.salience > 1.0) {
      errors.add('dream_anchor.salience must be 0..1');
    }
    if (s.dreamAnchor.progress.value < 0.0 ||
        s.dreamAnchor.progress.value > 1.0) {
      errors.add('dream_progress.value must be 0..1');
    }

    final count = s.frameOptions.options.length;
    final minMax = _optionsRangeForAge(s.ageMode);
    if (count < minMax.min || count > minMax.max) {
      errors.add(
          'options.length must be ${minMax.min}..${minMax.max} for age_mode=${s.ageMode}');
    }
    final seen = <String>{};
    for (final o in s.frameOptions.options) {
      if (o.optionId.isEmpty) errors.add('option_id empty');
      if (seen.contains(o.optionId)) errors.add('option_id duplicate');
      seen.add(o.optionId);

      if (o.timeCostMin < 0) errors.add('time_cost_min must be >= 0');

      if (o.worldEffectPreview.dreamDelta < -1.0 ||
          o.worldEffectPreview.dreamDelta > 1.0) {
        errors.add('dream_delta out of [-1,+1]');
      }
    }

    if (s.frameOptions.frameRationale.childReason.length > 2) {
      errors.add('child_reason length must be <= 2');
    }
    if (s.frameOptions.frameConfidence < 0.0 ||
        s.frameOptions.frameConfidence > 1.0) {
      errors.add('frame_confidence must be 0..1');
    }

    for (final r in s.frameOptions.frameRationale.childReason) {
      if (JudgementLint.containsJudgement(r)) {
        errors.add('judgement lint fail in child_reason');
      }
    }
    if (s.learningUpdate?.nextFrameHint != null) {
      if (JudgementLint.containsJudgement(s.learningUpdate!.nextFrameHint!)) {
        errors.add('judgement lint fail in next_frame_hint');
      }
    }
    if (s.reflection?.responseValue != null) {
      if (JudgementLint.containsJudgement(s.reflection!.responseValue)) {
        errors.add('judgement lint fail in reflection.response_value');
      }
    }

    if (s.chosenOption != null) {
      final c = s.chosenOption!;
      if (!seen.contains(c.selectedOptionId)) {
        errors.add('selected_option_id must exist in frame_options.options');
      }
      if (c.decisionLatencyMs < 0) {
        errors.add('decision_latency_ms must be >= 0');
      }
      if (c.overrideFlag && c.choiceMode == ChoiceMode.tap) {
        errors.add('override_flag=true requires parent-assisted choice_mode');
      }
    }

    if (s.worldResponse != null) {
      final w = s.worldResponse!;
      if (w.actualTimeSpentMin < 0) {
        errors.add('actual_time_spent_min must be >= 0');
      }
      if (w.celebrationShown &&
          !(w.outcome == WorldOutcome.completed ||
              w.outcome == WorldOutcome.partial)) {
        errors.add('celebration_shown only for completed/partial');
      }
    }

    if (s.reflection != null) {
      final r = s.reflection!;
      if (r.promptId.isEmpty) errors.add('reflection.prompt_id required');

      if (r.responseFormat == ResponseFormat.emoji ||
          r.responseFormat == ResponseFormat.oneTap) {
        if (r.responseValue.isEmpty) {
          errors.add('reflection.response_value required');
        }
      } else {
        if (r.responseValue.length > 256) {
          errors
              .add('reflection.response_value too long (max 256 in v1 tests)');
        }
      }
    }

    if (s.learningUpdate != null) {
      final u = s.learningUpdate!;
      if (u.nextFrameHintPresent && (u.nextFrameHint == null)) {
        errors.add('next_frame_hint_present=true but next_frame_hint is null');
      }
      if (u.nextFrameHint != null && u.nextFrameHint!.length > 160) {
        errors.add('next_frame_hint max 1 sentence (enforced as <=160 chars)');
      }
      if (u.updatedFields.contains(LearningUpdatedField.bufferAdjusted) &&
          !u.parameterDeltasPresent) {
        errors.add(
            'updated_fields contains bufferAdjusted but parameter_deltas_present=false');
      }
    }

    return errors.isEmpty ? ValidatorResult.ok() : ValidatorResult.fail(errors);
  }

  static ({int min, int max}) _optionsRangeForAge(AgeMode ageMode) {
    switch (ageMode) {
      case AgeMode.mini:
        return (min: 1, max: 2);
      case AgeMode.junior:
        return (min: 1, max: 3);
      case AgeMode.pro:
        return (min: 1, max: 4);
    }
  }
}
