import 'package:flutter/material.dart';
import 'package:metronom/providers/metronome.dart';
import 'package:provider/provider.dart';

class Visualization extends StatelessWidget {
  final int beatsPerBar;

  Visualization(this.beatsPerBar);

  Color _calculateColor(int index, int currentBarBeat) {
    double opacity = (index + 1 == currentBarBeat) ? 1.0 : 0.2;
    return Color.fromRGBO(255, index == 0 ? 0 : 255, 0, opacity);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
          beatsPerBar,
          (index) => CircleAvatar(
                backgroundColor: _calculateColor(
                    index, Provider.of<Metronome>(context).currentBarBeat),
              )),
    );
  }
}
