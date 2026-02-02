import 'package:flutter/material.dart';

import '../core_decision_runner.dart';
import '../demo_app_state.dart';
import '../demo_catalog.dart';

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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ZADANIA',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            'Katalog "na teraz" (${missions.length}) — bez tekstu, tylko ID + parametry',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: missions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final m = missions[idx];
                final selected = state.selectedMissionId == m.missionId;

                return Card(
                  child: ListTile(
                    title: Text(m.missionId),
                    subtitle: Text(
                      'type=${m.type.name} • effort=${m.effort.name} • time=${m.timeCostMin}m • dreamΔ=${m.dreamDelta}',
                    ),
                    trailing: selected ? const Icon(Icons.check_circle) : null,
                    onTap: () {
                      final updatedCatalog = DemoCatalog.withSelectedFirst(
                          state.catalog, m.missionId);

                      final out = CoreDecisionRunner.decide(
                        input: state.input,
                        catalog: updatedCatalog,
                      );

                      onStateChanged(
                        state.copyWith(
                          selectedMissionId: m.missionId,
                          catalog: updatedCatalog,
                          lastOutput: out,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          FilledButton(
            onPressed: () {
              final resetCatalog = DemoCatalog.defaultCatalog();
              final out = CoreDecisionRunner.decide(
                input: state.input,
                catalog: resetCatalog,
              );

              onStateChanged(
                state.copyWith(
                  selectedMissionId: null,
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
