import 'package:flutter/material.dart';

import '../models/track.dart';
import 'visualization.dart';

class PlaySimpleTrackPanel extends StatelessWidget {
  final Track track;

  PlaySimpleTrackPanel(this.track);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Visualization(track.beatsPerBar),
        ),
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
