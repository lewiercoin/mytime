import 'package:flutter/material.dart';
import 'package:mytime/timechoice/timechoice.dart';

class MissionDonePanel extends StatefulWidget {
  final String missionId;
  final int suggestedTimeMin;
  final void Function(int actualTimeMin, WorldOutcome outcome) onConfirm;

  const MissionDonePanel({
    super.key,
    required this.missionId,
    required this.suggestedTimeMin,
    required this.onConfirm,
  });

  @override
  State<MissionDonePanel> createState() => _MissionDonePanelState();
}

class _MissionDonePanelState extends State<MissionDonePanel> {
  late double _time;
  WorldOutcome _outcome = WorldOutcome.completed;

  @override
  void initState() {
    super.initState();
    _time = widget.suggestedTimeMin.toDouble().clamp(0, 240);
  }

  @override
  Widget build(BuildContext context) {
    final t = _time.round();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ZROBIONE! • ${widget.missionId}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text('Ile realnie zajęło?  $t min'),
          Slider(
            value: _time,
            min: 0,
            max: 120,
            divisions: 24,
            label: '$t',
            onChanged: (v) => setState(() => _time = v),
          ),
          const SizedBox(height: 8),
          const Text('Jak poszło?',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Ukończone'),
                selected: _outcome == WorldOutcome.completed,
                onSelected: (_) =>
                    setState(() => _outcome = WorldOutcome.completed),
              ),
              ChoiceChip(
                label: const Text('Częściowo'),
                selected: _outcome == WorldOutcome.partial,
                onSelected: (_) =>
                    setState(() => _outcome = WorldOutcome.partial),
              ),
              ChoiceChip(
                label: const Text('Nie wyszło'),
                selected: _outcome == WorldOutcome.abandoned,
                onSelected: (_) =>
                    setState(() => _outcome = WorldOutcome.abandoned),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onConfirm(t, _outcome);
                Navigator.of(context).pop();
              },
              child: const Text('OK, zatwierdź'),
            ),
          ),
        ],
      ),
    );
  }
}
