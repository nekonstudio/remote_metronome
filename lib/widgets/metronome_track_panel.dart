import 'package:flutter/material.dart';
import 'package:metronom/providers/setlist_player/setlist_player_interface.dart';

import 'animated_track_sections.dart';
import 'visualization.dart';

class MetronomeTrackPanel extends StatelessWidget {
  final SetlistPlayerInterface player;

  const MetronomeTrackPanel(this.player);

  @override
  Widget build(BuildContext context) {
    final track = player.currentTrack;
    final currentSection = player.currentSection;
    final isTrackComplex = track.isComplex;
    final metronomeSettings = isTrackComplex ? currentSection.settings : track.settings;

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Visualization(metronomeSettings.beatsPerBar),
        ),
        Expanded(
          flex: 3,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              '${metronomeSettings.tempo}',
              style: TextStyle(fontSize: 60),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: isTrackComplex ? AnimatedTrackSections(player, track.sections) : Container(),
        )
      ],
    );
  }
}
