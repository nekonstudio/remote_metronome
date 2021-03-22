import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../metronome/providers/metronome_provider.dart';
import '../../metronome/providers/simple_metronome_settings_controller_provider.dart';
import '../../remote_synchronization/logic/remote_commands/set_metronome_settings_command.dart';
import '../../remote_synchronization/logic/remote_commands/set_setlist_command.dart';
import '../../remote_synchronization/logic/remote_commands/stop_track_command.dart';
import '../../remote_synchronization/providers/is_remote_setlist_screen_provider.dart';
import '../../remote_synchronization/providers/remote_synchronization_provider.dart';
import '../../remote_synchronization/widgets/remote_mode_screen.dart';
import '../logic/setlist_player/notifier_setlist_player.dart';
import '../models/setlist.dart';
import '../providers/setlist_manager_provider.dart';
import '../providers/setlist_player_provider.dart';
import '../widgets/metronome_track_panel.dart';
import '../widgets/player_control_panel.dart';
import '../widgets/track_list.dart';
import 'track_screen.dart';

class SetlistScreen extends StatelessWidget {
  final Setlist setlist;

  SetlistScreen(this.setlist);

  final _scrollController = ItemScrollController();

  @override
  Widget build(BuildContext context) {
    final synchronization = context.read(synchronizationProvider);

    if (synchronization.synchronizationMode.isSynchronized) {
      Future.delayed(
        Duration(milliseconds: 50),
        () => context.read(isRemoteSetlistScreenProvider).changeState(true),
      );

      synchronization.broadcastRemoteCommand(
        SetSetlistCommand(setlist),
      );
    }

    return RemoteModeScreen(
      title: Consumer(
        builder: (context, watch, child) {
          final player = watch(setlistPlayerProvider(setlist));
          final selectedTrack = player.currentTrack;

          if (!setlist.hasTracks || selectedTrack == null) {
            return Text(setlist.name);
          }

          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              selectedTrack.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(setlist.name),
          );
        },
      ),
      body: WillPopScope(
        onWillPop: () {
          if (synchronization.synchronizationMode.isSynchronized) {
            synchronization.broadcastRemoteCommand(StopTrackCommand());

            final metronomeSettings = context.read(simpleMetronomeSettingsControllerProvider).value;
            synchronization.broadcastRemoteCommand(
              SetMetronomeSettingsCommand(metronomeSettings),
            );
          }

          context.read(setlistPlayerProvider(setlist)).stop();
          context.read(isRemoteSetlistScreenProvider).changeState(false);

          return Future.value(true);
        },
        child: Consumer(
          builder: (context, watch, child) {
            watch(setlistManagerProvider);

            final player = watch(setlistPlayerProvider(setlist));
            player.onTrackChanged = _onTrackChanged;

            return setlist.hasTracks ? _buildSetlist(player) : _buildEmptySetlist();
          },
        ),
      ),
      floatingActionButton: Consumer(
        builder: (context, watch, child) {
          final isPlaying = watch(metronomeProvider).isPlaying;
          return FloatingActionButton(
            backgroundColor: isPlaying ? Colors.grey : Theme.of(context).accentColor,
            child: Icon(Icons.add),
            onPressed: () {
              if (!isPlaying) {
                Get.to(TrackScreen(setlistId: setlist.id));
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildSetlist(NotifierSetlistPlayer player) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Expanded(flex: 4, child: MetronomeTrackPanel(player)),
          PlayerControlPanel(player),
          Expanded(
            flex: 6,
            child: TrackList(setlist, player, scrollController: _scrollController),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySetlist() {
    return Center(
      child: Text('Brak utworów w setliście'),
    );
  }

  void _onTrackChanged(int currentIndex) {
    _scrollController.scrollTo(
      index: currentIndex,
      duration: Duration(milliseconds: 300),
    );
  }
}
