import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class CelebrationOverlay {
  static Future<void> show(BuildContext context) async {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => const _ConfettiLayer(),
    );
    overlay.insert(entry);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    entry.remove();
  }
}

class _ConfettiLayer extends StatefulWidget {
  const _ConfettiLayer();

  @override
  State<_ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<_ConfettiLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Timer _timer;

  final _rng = Random(7);
  final _pieces = List.generate(40, (i) {
    return _Piece(
      x: (i % 10) / 10.0,
      y: -0.1 * (i % 5),
      speed: 0.6 + (i % 7) * 0.08,
      char: ['🎉', '✨', '🎊'][i % 3],
      size: 18 + (i % 6) * 2.0,
    );
  });

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();

    // small random drift over time
    _timer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      if (!mounted) return;
      setState(() {
        for (var i = 0; i < _pieces.length; i++) {
          final p = _pieces[i];
          _pieces[i] = p.copyWith(
            x: (p.x + (_rng.nextDouble() - 0.5) * 0.03).clamp(0.0, 1.0),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          return Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                for (final p in _pieces)
                  Positioned(
                    left: MediaQuery.of(context).size.width * p.x,
                    top: MediaQuery.of(context).size.height *
                        (p.y + t * p.speed),
                    child: Opacity(
                      opacity: (1.0 - t).clamp(0.0, 1.0),
                      child: Text(
                        p.char,
                        style: TextStyle(fontSize: p.size),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Piece {
  final double x;
  final double y;
  final double speed;
  final String char;
  final double size;

  _Piece({
    required this.x,
    required this.y,
    required this.speed,
    required this.char,
    required this.size,
  });

  _Piece copyWith({double? x}) {
    return _Piece(
      x: x ?? this.x,
      y: y,
      speed: speed,
      char: char,
      size: size,
    );
  }
}
