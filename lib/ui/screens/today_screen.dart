import 'package:flutter/material.dart';
import 'package:mytime/timechoice/timechoice.dart';

import '../core_decision_runner.dart';
import '../demo_app_state.dart';
import 'celebration_overlay.dart';
import 'mission_done_panel.dart';

class TodayScreen extends StatelessWidget {
  final DemoAppState state;
  final ValueChanged<DemoAppState> onStateChanged;

  const TodayScreen({
    super.key,
    required this.state,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final output = state.lastOutput ??
        CoreDecisionRunner.decide(
          input: state.input,
          catalog: state.catalog,
        );

    // Persist last output for quick navigation.
    if (state.lastOutput == null) {
      onStateChanged(state.copyWith(lastOutput: output));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DZIŚ',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _TimeCard(
            minutes: state.input.timeRemainingMin,
            block: state.input.currentTimeBlock,
          ),
          const SizedBox(height: 12),
          _RecommendationCard(output: output),
          const SizedBox(height: 12),
          _MiniMetaCard(output: output),
          const SizedBox(height: 12),
          _CompletedMiniList(completed: state.completed),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final refreshed = state.input;
                    final updated = OrchestratorInputV1(
                      currentTimeUtc: DateTime.now().toUtc(),
                      timeRemainingMin: refreshed.timeRemainingMin,
                      currentTimeBlock: refreshed.currentTimeBlock,
                      childId: refreshed.childId,
                      ageMode: refreshed.ageMode,
                      surface: refreshed.surface,
                      activeGoalId: refreshed.activeGoalId,
                      progressToGoal: refreshed.progressToGoal,
                      coldStart: refreshed.coldStart,
                      parentConstraints: refreshed.parentConstraints,
                    );

                    final out = CoreDecisionRunner.decide(
                      input: updated,
                      catalog: state.catalog,
                    );

                    onStateChanged(
                        state.copyWith(input: updated, lastOutput: out));
                  },
                  child: const Text('Odśwież'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {
                    final missionId = output.mainOptionId;

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => MissionDonePanel(
                        missionId: missionId,
                        suggestedTimeMin: 20,
                        onConfirm: (actualTimeMin, outcome) async {
                          await CelebrationOverlay.show(context);

                          final newCompleted = [
                            ...state.completed,
                            CompletedMissionRecord(
                              missionId: missionId,
                              completedAtUtc: DateTime.now().toUtc(),
                              actualTimeSpentMin: actualTimeMin,
                              outcome: outcome,
                              approvalState: ParentApprovalState.pending,
                            ),
                          ];

                          final newOut = CoreDecisionRunner.decideAfterDone(
                            input: state.input,
                            catalog: state.catalog,
                            missionId: missionId,
                            actualTimeSpentMin: actualTimeMin,
                            outcome: outcome,
                          );

                          onStateChanged(
                            state.copyWith(
                              completed: newCompleted,
                              lastOutput: newOut,
                            ),
                          );
                        },
                      ),
                    );
                  },
                  child: const Text('ZROBIONE!'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletedMiniList extends StatelessWidget {
  final List<CompletedMissionRecord> completed;

  const _CompletedMiniList({required this.completed});

  String _badge(ParentApprovalState st) {
    switch (st) {
      case ParentApprovalState.pending:
        return '⏳ CZEKA';
      case ParentApprovalState.approved:
        return '✅ OK';
      case ParentApprovalState.rejected:
        return '❌ NIE';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (completed.isEmpty) {
      return const Text(
        'Brak ukończonych misji (w tej sesji).',
        style: TextStyle(color: Colors.black54),
      );
    }

    final last = completed.reversed.take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ostatnio ukończone',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final r in last)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${_badge(r.approvalState)} ${r.missionId} (${r.outcome.name}, ${r.actualTimeSpentMin}m)',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  final int minutes;
  final TimeBlockV1 block;

  const _TimeCard({required this.minutes, required this.block});

  @override
  Widget build(BuildContext context) {
    final h = minutes ~/ 60;
    final m = minutes % 60;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.schedule, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Masz ${h}h ${m}m wolnego • blok: ${block.name}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final OrchestratorOutputV1 output;

  const _RecommendationCard({required this.output});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Twoja misja na teraz',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              output.mainOptionId,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (output.alternativeOptionIds.isNotEmpty) ...[
              const Text('Alternatywy (max 2):',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              for (final alt in output.alternativeOptionIds)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $alt'),
                ),
            ] else
              const Text('Brak alternatyw w tym układzie.'),
          ],
        ),
      ),
    );
  }
}

class _MiniMetaCard extends StatelessWidget {
  final OrchestratorOutputV1 output;

  const _MiniMetaCard({required this.output});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Pewność: ${(output.frameConfidence * 100).round()}%',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              output.scoringConfigVersion,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
