import '../dto/time_choice_loop_snapshot.dart';
import '../enums/age_mode.dart';
import '../enums/surface.dart';
import '../enums/context_trigger.dart';
import '../enums/option_type.dart';
import '../enums/option_effort.dart';
import '../enums/eligibility_reason_code.dart';
import '../validators/snapshot_validator.dart';
import 'seedable_random.dart';

class PropertyGenerator {
  final SeedableRandom rng;

  PropertyGenerator({required int seed}) : rng = SeedableRandom(seed);

  TimeChoiceLoopSnapshot generateValidSnapshot({
    AgeMode? ageMode,
    Surface? surface,
    ContextTrigger? trigger,
    bool? dreamPresent,
    bool includeScoringTrace = false,
  }) {
    final now = DateTime.now().toUtc();
    final a = (ageMode ?? rng.pick(AgeMode.values))!;
    final s = (surface ?? rng.pick(Surface.values))!;
    final t = (trigger ?? rng.pick(ContextTrigger.values))!;

    final duration = rng.intInRange(5, 240);
    final buffer = rng.doubleInRange(0.0, 0.5);
    final hardBlocks = _randomHardBlocksCodes();

    final eLevel = rng.intInRange(1, 3);
    final eSource = rng.pick(EnergySource.values);
    final eConf = _energyConfidence(eSource);

    final dPresent = dreamPresent ?? rng.boolWithProb(0.6);
    final dId = dPresent ? rng.alphaNumId(prefix: 'dream') : null;
    final salience = dPresent ? rng.doubleInRange(0.0, 1.0) : 0.0;
    final horizon = rng.pick(DreamHorizon.values);
    final progress = rng.doubleInRange(0.0, 1.0);

    final allowedMode = rng.pick(AllowedMode.values);
    final blockedTypes = _randomBlockedTypes();
    final isQuiet = rng.boolWithProb(0.2);

    final optionsCount = _optionsCountForAge(a);

    final effMin = duration * (1.0 - buffer);
    final options = <FramedOption>[];
    final usedIds = <String>{};

    for (var i = 0; i < optionsCount; i++) {
      final opt = _generateOption(
        usedIds: usedIds,
        effectiveMin: effMin,
        blockedTypes: blockedTypes,
        dreamPresent: dPresent,
        allowedMode: allowedMode,
        forceEdgeCase: EdgeCase.none,
      );
      options.add(opt);
    }

    final snapshot = TimeChoiceLoopSnapshot(
      snapshotId: rng.alphaNumId(prefix: 'snap'),
      timestampUtc: now,
      loopVersion: 'timechoice/v1',
      ageMode: a,
      surface: s,
      contextTrigger: t,
      subjectRef: rng.alphaNumId(prefix: 'subj'),
      familyRef: rng.boolWithProb(0.5) ? rng.alphaNumId(prefix: 'fam') : null,
      availableTimeWindow: AvailableTimeWindow(
        durationMin: duration,
        bufferRatio: buffer,
        constraints: TimeConstraints(hardBlocksCodes: hardBlocks),
      ),
      energyState:
          EnergyState(level: eLevel, source: eSource, confidence: eConf),
      dreamAnchor: DreamAnchor(
        dreamId: dId,
        horizon: horizon,
        salience: salience,
        progress: DreamProgress(value: progress),
      ),
      parentFrame: ParentFrame(
        allowedMode: allowedMode,
        blockedTypes: blockedTypes,
        isNowInQuietHours: isQuiet,
      ),
      frameOptions: FrameOptions(
        options: options,
        frameConfidence: 0.5,
        frameRationale:
            FrameRationale(childReason: const [], parentReasonPresent: false),
        scoringTrace: null,
      ),
      chosenOption: null,
      worldResponse: null,
      reflection: null,
      learningUpdate: null,
    );

    final res = SnapshotValidator.validate(snapshot);
    if (!res.ok) {
      throw StateError('Generated snapshot is invalid: ${res.errors}');
    }

    return snapshot;
  }

  TimeChoiceLoopSnapshot generateEdgeCaseTimeOverflow({required int seed}) {
    final base = PropertyGenerator(seed: seed).generateValidSnapshot();
    final effMin = base.availableTimeWindow.effectiveMin;

    final options = [...base.frameOptions.options];
    final o0 = options.first;

    options[0] = FramedOption(
      optionId: o0.optionId,
      type: o0.type,
      effort: o0.effort,
      timeCostMin: (effMin.ceil() + 10),
      eligibility: Eligibility(
        isAllowedByParentFrame: true,
        fitsTimeWindow: false,
        hardBlockHit: false,
        reasonCodes: const [EligibilityReasonCode.timeOverflow],
      ),
      worldEffectPreview: o0.worldEffectPreview,
    );

    final mutated = TimeChoiceLoopSnapshot(
      snapshotId: base.snapshotId,
      timestampUtc: base.timestampUtc,
      loopVersion: base.loopVersion,
      ageMode: base.ageMode,
      surface: base.surface,
      contextTrigger: base.contextTrigger,
      subjectRef: base.subjectRef,
      familyRef: base.familyRef,
      availableTimeWindow: base.availableTimeWindow,
      energyState: base.energyState,
      dreamAnchor: base.dreamAnchor,
      parentFrame: base.parentFrame,
      frameOptions: FrameOptions(
        options: options,
        frameConfidence: base.frameOptions.frameConfidence,
        frameRationale: base.frameOptions.frameRationale,
        scoringTrace: base.frameOptions.scoringTrace,
      ),
      chosenOption: base.chosenOption,
      worldResponse: base.worldResponse,
      reflection: base.reflection,
      learningUpdate: base.learningUpdate,
    );

    final res = SnapshotValidator.validate(mutated);
    if (!res.ok) {
      throw StateError('Edge snapshot invalid: ${res.errors}');
    }

    return mutated;
  }

  List<String> _randomHardBlocksCodes() {
    const pool = ['school', 'sleep', 'family', 'quiet_hours', 'commute'];
    final n = rng.intInRange(0, 3);
    final set = <String>{};
    for (var i = 0; i < n; i++) {
      set.add(rng.pick(pool));
    }
    return set.toList()..sort();
  }

  List<OptionType> _randomBlockedTypes() {
    final blocked = <OptionType>[];
    for (final t in OptionType.values) {
      if (rng.boolWithProb(0.1)) blocked.add(t);
    }
    return blocked;
  }

  double _energyConfidence(EnergySource src) {
    switch (src) {
      case EnergySource.selfReported:
        return rng.doubleInRange(0.6, 1.0);
      case EnergySource.mixed:
        return rng.doubleInRange(0.4, 1.0);
      case EnergySource.inferred:
        return rng.doubleInRange(0.2, 0.8);
    }
  }

  int _optionsCountForAge(AgeMode age) {
    final range = switch (age) {
      AgeMode.mini => (min: 1, max: 2),
      AgeMode.junior => (min: 1, max: 3),
      AgeMode.pro => (min: 1, max: 4),
    };
    return rng.intInRange(range.min, range.max);
  }

  FramedOption _generateOption({
    required Set<String> usedIds,
    required double effectiveMin,
    required List<OptionType> blockedTypes,
    required bool dreamPresent,
    required AllowedMode allowedMode,
    required EdgeCase forceEdgeCase,
  }) {
    final id = _uniqueId(usedIds, prefix: 'opt');
    final type = rng.pick(OptionType.values);
    final effort = rng.pick(OptionEffort.values);

    final t = rng.intInRange(0, effectiveMin.floor().clamp(0, 240));

    final isBlocked = blockedTypes.contains(type);
    final isAllowed = !isBlocked;

    final dreamDelta = dreamPresent
        ? rng.doubleInRange(-1.0, 1.0)
        : rng.doubleInRange(-1.0, 1.0);

    Eligibility eligibility;
    if (!isAllowed) {
      eligibility = Eligibility(
        isAllowedByParentFrame: false,
        fitsTimeWindow: true,
        hardBlockHit: false,
        reasonCodes: const [EligibilityReasonCode.blockedByParent],
      );
    } else {
      eligibility = Eligibility(
        isAllowedByParentFrame: true,
        fitsTimeWindow: true,
        hardBlockHit: false,
        reasonCodes: const [],
      );
    }

    return FramedOption(
      optionId: id,
      type: type,
      effort: effort,
      timeCostMin: t,
      eligibility: eligibility,
      worldEffectPreview: WorldEffectPreview(
        dreamDelta: dreamDelta,
        moneyDelta: rng.boolWithProb(0.2) ? rng.intInRange(-100, 100) : null,
      ),
    );
  }

  String _uniqueId(Set<String> used, {required String prefix}) {
    while (true) {
      final id = rng.alphaNumId(prefix: prefix);
      if (!used.contains(id)) {
        used.add(id);
        return id;
      }
    }
  }
}

enum EdgeCase { none }
