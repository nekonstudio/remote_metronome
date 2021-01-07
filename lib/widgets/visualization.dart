import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/metronome/metronome_base.dart';

class Visualization extends ConsumerWidget {
  final int beatsPerBar;

  Visualization(this.beatsPerBar);

  Color _calculateColor(int index, int currentBarBeat) {
    double opacity = (index + 1 == currentBarBeat) ? 1.0 : 0.2;
    return Color.fromRGBO(255, index == 0 ? 0 : 255, 0, opacity);
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final currentBarBeat = watch(currentBeatBarProvider);
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          beatsPerBar,
          (index) => CircleAvatar(
              backgroundColor: _calculateColor(
            index,
            currentBarBeat,
          )),
        ));
  }
}
