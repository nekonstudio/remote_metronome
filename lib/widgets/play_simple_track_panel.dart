import 'package:flutter/material.dart';
import 'package:metronom/models/track.dart';
import 'package:metronom/providers/metronome.dart';
import 'package:metronom/widgets/visualization.dart';

class PlaySimpleTrackPanel extends StatelessWidget {
  final Track track;
  final Metronome metronome;

  PlaySimpleTrackPanel(this.track, this.metronome) {
    metronome.setBarCompletedCallback(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            flex: 3,
            child: Visualization(track.beatsPerBar, metronome.currentBarBeat)),
        Expanded(
          flex: 3,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              '${track.tempo}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 60),
            ),
          ),
        ),
        Expanded(flex: 2, child: SizedBox()),
      ],
    );
  }
}
