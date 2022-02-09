import 'package:flutter/material.dart';

import '../../setlists/logic/setlist_player/setlist_player_interface.dart';
import '../../setlists/widgets/animated_track_sections.dart';
import 'remote_metronome_panel_widget_list.dart';
import 'widget_list.dart';

class RemoteMetronomeTrackPanelWidgetList implements WidgetList {
  final SetlistPlayerInterface setlistPlayer;

  const RemoteMetronomeTrackPanelWidgetList({
    required this.setlistPlayer,
  });

  @override
  List<Widget> getWidgetList() {
    final currentTrack = setlistPlayer.currentTrack!;
    final metronomeSettings =
        currentTrack.isComplex! ? setlistPlayer.currentSection!.settings : currentTrack.settings;

    return [
      ...RemoteMetronomePanelWidgetList(metronomeSettings: metronomeSettings).getWidgetList(),
      SizedBox(
        height: 20,
      ),
      Text(
        '${setlistPlayer.setlist.name} - ${currentTrack.name}',
        style: TextStyle(fontSize: 16),
      ),
      SizedBox(
        height: 30,
      ),
      if (currentTrack.isComplex!)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          color: Colors.black38,
          child: AnimatedTrackSections(
            setlistPlayer,
            currentTrack.sections,
          ),
        ),
    ];
  }
}
