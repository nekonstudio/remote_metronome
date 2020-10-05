import 'package:flutter/material.dart';

class Visualization extends StatelessWidget {
  final int beatsPerBar;
  final int currentBarBeat;

  Visualization(this.beatsPerBar, this.currentBarBeat);

  Color _calculateColor(int index) {
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
                backgroundColor: _calculateColor(index),
              )),
    );
  }
}
