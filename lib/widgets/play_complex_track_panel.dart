import 'package:flutter/material.dart';

import '../models/track.dart';
import '../providers/setlist_player/notifier_setlist_player.dart';
import 'animated_track_sections.dart';
import 'visualization.dart';

class PlayComplexTrackPanel extends StatelessWidget {
  final NotifierSetlistPlayer player;
  final Track track;

  const PlayComplexTrackPanel(this.player, this.track);

  @override
  Widget build(BuildContext context) {
    final currentSection = track.sections[player.currentSectionIndex];

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Visualization(currentSection.settings.beatsPerBar),
        ),
        Expanded(
          flex: 3,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              '${currentSection.settings.tempo}',
              style: TextStyle(fontSize: 60),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: AnimatedTrackSections(player, track.sections),
        )
      ],
    );
  }
}
