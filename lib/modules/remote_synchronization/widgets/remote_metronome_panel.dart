import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../setlists/providers/setlist_player_provider.dart';
import '../providers/remote_metronome_screen_controller_provider.dart';
import '../providers/remote_screen_state_provider.dart';
import 'remote_metronome_panel_widget_list.dart';
import 'remote_metronome_track_panel_widget_list.dart';
import 'widget_list.dart';

class RemoteMetronomePanel extends ConsumerWidget {
  final String hostName;
  final Function showEndDialog;

  const RemoteMetronomePanel(this.hostName, this.showEndDialog);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final controller = watch(remoteMetronomeScreenControllerProvider);
    if (!controller.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    final state = watch(remoteScreenStateProvider.state);

    WidgetList metronomePanel = state == ScreenState.SimpleMetronome
        ? RemoteMetronomePanelWidgetList(metronomeSettings: controller.metronomeSettings)
        : RemoteMetronomeTrackPanelWidgetList(
            setlistPlayer: watch(
              setlistPlayerProvider(context.read(remoteScreenStateProvider).setlist),
            ),
          );

    return Padding(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              RichText(
                text: TextSpan(
                  text: 'Odtwarzaniem zarządza ',
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                      text: hostName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ...metronomePanel.getWidgetList(),
            ],
          ),
          RaisedButton(
            child: Text('Zakończ'),
            onPressed: () async {
              final isEnded = await showEndDialog();
              if (isEnded) {
                Get.back();
              }
            },
          ),
        ],
      ),
    );
  }
}
