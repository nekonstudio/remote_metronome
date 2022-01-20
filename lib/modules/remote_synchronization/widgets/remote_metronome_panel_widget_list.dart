import 'package:flutter/material.dart';

import 'package:metronom/modules/metronome/models/metronome_settings.dart';
import 'package:metronom/modules/metronome/widgets/metronome_visualization.dart';
import 'package:metronom/modules/remote_synchronization/widgets/widget_list.dart';

class RemoteMetronomePanelWidgetList implements WidgetList {
  final MetronomeSettings? metronomeSettings;

  const RemoteMetronomePanelWidgetList({
    required this.metronomeSettings,
  });

  @override
  List<Widget> getWidgetList() {
    return [
      SizedBox(
        height: 50,
      ),
      MetronomeVisualization(metronomeSettings!.beatsPerBar),
      SizedBox(
        height: 30,
      ),
      Text(
        metronomeSettings!.tempo.toString(),
        style: TextStyle(fontSize: 60),
        textAlign: TextAlign.center,
      ),
    ];
  }
}
