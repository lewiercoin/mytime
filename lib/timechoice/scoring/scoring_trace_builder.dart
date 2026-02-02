import 'dart:convert';
import 'dart:math';

import '../dto/time_choice_loop_snapshot.dart';
import '../enums/scoring_input_field.dart';

class ScoringTraceBuilder {
  final String scoreConfigVersion;
  final Random _rng;

  ScoringTraceBuilder({required this.scoreConfigVersion, int? seed}) : _rng = Random(seed);

  String newUuidV4() {
    String hex(int n) => n.toRadixString(16).padLeft(2, '0');
    final bytes = List<int>.generate(16, (_) => _rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final b = bytes.map(hex).toList();
    return '${b[0]}${b[1]}${b[2]}${b[3]}-${b[4]}${b[5]}-${b[6]}${b[7]}-${b[8]}${b[9]}-${b[10]}${b[11]}${b[12]}${b[13]}${b[14]}${b[15]}';
  }

  String computeInputsHash(TimeChoiceLoopSnapshot s, List<ScoringInputField> used) {
    final map = <String, Object?>{};

    for (final f in used) {
      map[f.name] = _extractField(s, f);
    }

    final canonical = jsonEncode(map);
    final bytes = utf8.encode(canonical);
    final checksum = bytes.fold<int>(0, (a, b) => (a + b) & 0xFFFFFFFF);
    return base64Url.encode(utf8.encode('$checksum:$canonical'));
  }

  Object? _extractField(TimeChoiceLoopSnapshot s, ScoringInputField f) {
    switch (f) {
      case ScoringInputField.availableTimeWindowDurationMin:
        return s.availableTimeWindow.durationMin;
      case ScoringInputField.availableTimeWindowBufferRatio:
        return s.availableTimeWindow.bufferRatio;
      case ScoringInputField.availableTimeWindowHardBlocksCodes:
        return [...s.availableTimeWindow.constraints.hardBlocksCodes]..sort();
      case ScoringInputField.energyStateLevel:
        return s.energyState.level;
      case ScoringInputField.energyStateSource:
        return s.energyState.source.name;
      case ScoringInputField.dreamIdPresent:
        return s.dreamAnchor.dreamIdPresent;
      case ScoringInputField.dreamHorizon:
        return s.dreamAnchor.horizon.name;
      case ScoringInputField.dreamSalience:
        return s.dreamAnchor.salience;
      case ScoringInputField.parentAllowedModes:
        return s.parentFrame.allowedMode.name;
      case ScoringInputField.parentBlockedTypes:
        return s.parentFrame.blockedTypes.map((e) => e.name).toList()..sort();
      case ScoringInputField.parentIsNowInQuietHours:
        return s.parentFrame.isNowInQuietHours;
    }
  }
}
