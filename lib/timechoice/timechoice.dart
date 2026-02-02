library mytime_timechoice;

// Enums
export 'enums/age_mode.dart';
export 'enums/surface.dart';
export 'enums/context_trigger.dart';
export 'enums/telemetry_event_type.dart';
export 'enums/option_type.dart';
export 'enums/option_effort.dart';
export 'enums/world_outcome.dart';
export 'enums/telemetry_source.dart';
export 'enums/response_format.dart';
export 'enums/friction_event.dart';
export 'enums/learning_updated_field.dart';
export 'enums/preferred_duration_band.dart';
export 'enums/eligibility_reason_code.dart';
export 'enums/scoring_input_field.dart';

// DTO
export 'dto/time_choice_loop_snapshot.dart';
export 'dto/scoring_trace.dart';
export 'dto/telemetry.dart';

// Validators
export 'validators/validator_result.dart';
export 'validators/snapshot_validator.dart';
export 'validators/scoring_trace_validator.dart';
export 'validators/telemetry_validator.dart';
export 'validators/judgement_lint.dart';
export 'validators/scoring_input_whitelist.dart';
export 'validators/score_config_validator.dart';

// Scoring + config
export 'scoring/scoring_engine.dart';
export 'scoring/scoring_trace_builder.dart';
export 'scoring/scoring_math.dart';
export 'scoring/config/score_config_v1.dart';

// Telemetry
export 'telemetry/snapshot_to_telemetry_mapper.dart';

// Runner (C.6)
export 'timechoice_loop_runner.dart';

// Generator (C.4)
export 'generator/seedable_random.dart';
export 'generator/property_generator.dart';
