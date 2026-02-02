import 'package:flutter/material.dart';

import '../core_decision_runner.dart';
import '../demo_app_state.dart';
import '../demo_catalog.dart';
import 'mission_detail_panel.dart';
import 'parent_approval_panel.dart';
import 'celebration_overlay.dart';

class TasksScreen extends StatelessWidget {
  final DemoAppState state;
  final ValueChanged<DemoAppState> onStateChanged;

  const TasksScreen({
    super.key,
    required this.state,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final missions = state.catalog.missions;
    final pending = state.pendingApprovals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZADANIA'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text('⏳ ${pending.length}'),
            ),
          ),
          IconButton(
            tooltip: 'Panel rodzica',
            icon: const Icon(Icons.verified_user_outlined),
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (ctx) {
                  return ParentApprovalPanel(
                    pending: pending,
                    onApprove: (missionId) async {
                      final updated = state.completed
                          .map((r) => r.missionId == missionId
                              ? r.copyWith(
                                  approvalState: ParentApprovalState.approved)
                              : r)
                          .toList(growable: false);

                      onStateChanged(state.copyWith(completed: updated));

                      Navigator.of(ctx).pop();

                      // druga celebracja po zatwierdzeniu (MVP restart)
                      await CelebrationOverlay.show(context);

                      if (context.mounted) {
                        showDialog<void>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('MASZ NAGRODĘ!'),
                            content: const Text('Super! Rodzic zatwierdził.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    onReject: (missionId) {
                      final updated = state.completed
                          .map((r) => r.missionId == missionId
                              ? r.copyWith(
                                  approvalState: ParentApprovalState.rejected)
                              : r)
                          .toList(growable: false);

                      onStateChanged(state.copyWith(completed: updated));
                      Navigator.of(ctx).pop();
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Do zrobienia',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text('Czekają: ${pending.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...missions.map((m) {
            return Card(
              child: ListTile(
                title: Text(m.missionId),
                subtitle: Text(
                  'type=${m.type.name} • effort=${m.effort.name} • time=${m.timeCostMin}m • dreamΔ=${m.dreamDelta}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    isScrollControlled: true,
                    builder: (_) => MissionDetailPanel(
                      mission: m,
                      state: state,
                      onStateChanged: onStateChanged,
                    ),
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              final resetCatalog = DemoCatalog.defaultCatalog();
              final out = CoreDecisionRunner.decide(
                input: state.input,
                catalog: resetCatalog,
              );
              onStateChanged(
                state.copyWith(
                  selectedMissionId: null,
                  chosenMissionId: null,
                  catalog: resetCatalog,
                  lastOutput: out,
                ),
              );
            },
            child: const Text('Reset katalogu demo'),
          ),
        ],
      ),
    );
  }
}
