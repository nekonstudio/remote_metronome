import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/metronome_provider.dart';

class MetronomeVisualization extends ConsumerWidget {
  final int beatsPerBar;

  MetronomeVisualization(this.beatsPerBar);

  Color _calculateColor(int index, int currentBarBeat) {
    double opacity = (index + 1 == currentBarBeat) ? 1.0 : 0.2;
    return Color.fromRGBO(255, index == 0 ? 0 : 255, 0, opacity);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBarBeat = ref.watch(currentBeatBarProvider);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            beatsPerBar <= 8 ? beatsPerBar : 8,
            (index) => CircleAvatar(
              backgroundColor: _calculateColor(
                index,
                currentBarBeat,
              ),
            ),
          ),
        ),
        if (beatsPerBar > 8) SizedBox(height: 5),
        if (beatsPerBar > 8)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              beatsPerBar - 8,
              (index) => CircleAvatar(
                backgroundColor: _calculateColor(
                  index + 8,
                  currentBarBeat,
                ),
              ),
            ),
          )
      ],
    );
  }
}
