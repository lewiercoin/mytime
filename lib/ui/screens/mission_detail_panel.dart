import 'package:flutter/material.dart';
import 'package:mytime/timechoice/timechoice.dart';

import '../demo_app_state.dart';
import '../core_decision_runner.dart';

class MissionDetailPanel extends StatefulWidget {
  final MissionV1 mission;
  final DemoAppState state;
  final ValueChanged<DemoAppState> onStateChanged;

  const MissionDetailPanel({
    super.key,
    required this.mission,
    required this.state,
    required this.onStateChanged,
  });

  @override
  State<MissionDetailPanel> createState() => _MissionDetailPanelState();
}

class _MissionDetailPanelState extends State<MissionDetailPanel> {
  late double _committedMinutes;

  @override
  void initState() {
    super.initState();
    _committedMinutes = widget.mission.timeCostMin.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.mission;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        color: Colors.white,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              m.missionId,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('type=${m.type.name} • effort=${m.effort.name}'),
            Text('dreamΔ=${m.dreamDelta} • moneyΔ=${m.moneyDelta ?? "—"}'),
            const SizedBox(height: 16),
            const Text('Ile czasu poświęcę (min):',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _committedMinutes,
                    min: 5,
                    max: 120,
                    divisions: 23,
                    label: '${_committedMinutes.round()} min',
                    onChanged: (v) => setState(() => _committedMinutes = v),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    '${_committedMinutes.round()} min',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                // E.2B: Update input.timeRemainingMin with committed time
                final updatedInput = OrchestratorInputV1(
                  currentTimeUtc: DateTime.now().toUtc(),
                  timeRemainingMin: _committedMinutes.round(),
                  currentTimeBlock: widget.state.input.currentTimeBlock,
                  childId: widget.state.input.childId,
                  ageMode: widget.state.input.ageMode,
                  surface: widget.state.input.surface,
                  activeGoalId: widget.state.input.activeGoalId,
                  progressToGoal: widget.state.input.progressToGoal,
                  coldStart:
                      false, // No longer cold start after explicit choice
                  parentConstraints: widget.state.input.parentConstraints,
                );

                // E.2B: Use decideWithChosen which moves mission to front and runs pipeline
                final out = CoreDecisionRunner.decideWithChosen(
                  input: updatedInput,
                  catalog: widget.state.catalog,
                  chosenMissionId: m.missionId,
                );

                widget.onStateChanged(
                  widget.state.copyWith(
                    input: updatedInput,
                    chosenMissionId: m.missionId,
                    selectedMissionId: m.missionId,
                    lastOutput: out,
                  ),
                );

                Navigator.of(context).pop();
              },
              child: const Text('Wybieram tę misję'),
            ),
          ],
        ),
      ),
    );
  }
}
