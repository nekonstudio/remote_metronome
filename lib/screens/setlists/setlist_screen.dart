import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:metronom/models/setlist.dart';
import 'package:metronom/providers/remote/remote_command.dart';
import 'package:metronom/providers/remote/remote_synchronization.dart';
import 'package:metronom/providers/setlist_player/notifier_setlist_player.dart';
import 'package:metronom/providers/setlist_player/remote_synchronized_notifier_setlist_player.dart';
import 'package:metronom/providers/setlist_player/setlist_player.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../mixins/list_item_long_press_popup_menu.dart';
import '../../models/track.dart';
import '../../providers/metronome/metronome_base.dart';
import '../../providers/setlists_manager.dart';
import '../../widgets/play_complex_track_panel.dart';
import '../../widgets/play_simple_track_panel.dart';
import '../../widgets/remote_mode_screen.dart';
import 'add_edit_track_screen.dart';

final setlistPlayerProvider =
    ChangeNotifierProvider.autoDispose.family<NotifierSetlistPlayer, Setlist>(
  (ref, setlist) => ref.watch(synchronizationProvider).deviceMode == DeviceSynchronizationMode.Host
      ? RemoteSynchronizedNotifierSetlistPlayer(ref.read(synchronizationProvider), setlist)
      : NotifierSetlistPlayer(setlist),
);

class SetlistScreen extends ConsumerWidget {
  final Setlist setlist;

  SetlistScreen(this.setlist);

  ItemScrollController _scrollController = ItemScrollController();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    watch(setlistManagerProvider);

    final synchronization = context.read(synchronizationProvider);

    if (synchronization.isSynchronized) {
      synchronization.sendRemoteCommand(
        RemoteCommand.setSetlist(setlist),
      );
    }

    return Consumer(
      builder: (context, watch, child) {
        final player = watch(setlistPlayerProvider(setlist));
        player.onTrackChanged = _onTrackChanged;

        return WillPopScope(
          onWillPop: () {
            _handleRemoteSynchronization(synchronization);

            player.stop();

            return Future.value(true);
          },
          child: setlist.hasTracks ? _buildSetlistScreen(player) : _buildEmptySetlistScreen(),
        );
      },
    );
  }

  RemoteModeScreen _buildSetlistScreen(NotifierSetlistPlayer player) {
    final selectedTrack = player.currentTrack;

    return RemoteModeScreen(
      title: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          selectedTrack.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(setlist.name),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: selectedTrack.isComplex
                        ? PlayComplexTrackPanel(player, selectedTrack)
                        : PlaySimpleTrackPanel(selectedTrack),
                  ),
                ],
              ),
            ),
            _PlayerPanel(player),
            Expanded(
              flex: 6,
              child: _TrackList(setlist, player, scrollController: _scrollController),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  RemoteModeScreen _buildEmptySetlistScreen() {
    return RemoteModeScreen(
      title: Text(setlist.name),
      body: Center(
        child: Text('Brak utworów w setliście'),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() => Consumer(
        builder: (context, watch, child) {
          final isPlaying = watch(metronomeProvider).isPlaying;
          return FloatingActionButton(
            backgroundColor: isPlaying ? Colors.grey : Theme.of(context).accentColor,
            child: Icon(Icons.add),
            onPressed: () {
              if (!isPlaying) {
                Get.to(AddEditTrackScreen(setlist.id, null));
              }
            },
          );
        },
      );

  void _handleRemoteSynchronization(RemoteSynchronization synchronization) {
    if (synchronization.isSynchronized) {
      synchronization.sendRemoteCommand(
        RemoteCommand.stopTrack(),
      );

      final metronomeSettings = synchronization.simpleMetronomeSettingsGetter();
      synchronization.sendRemoteCommand(
        RemoteCommand.setMetronomeSettings(metronomeSettings),
      );
    }
  }

  void _onTrackChanged(int currentIndex) {
    _scrollController.scrollTo(
      index: currentIndex,
      duration: Duration(milliseconds: 300),
    );
  }
}

class _PlayerPanel extends ConsumerWidget {
  final SetlistPlayer player;

  _PlayerPanel(this.player);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final Map<IconData, Function> options = {
      Icons.skip_previous: player.selectPreviousTrack,
      Icons.fast_rewind: player.selectPreviousSection,
      player.isPlaying ? Icons.stop : Icons.play_arrow: () {
        player.isPlaying ? player.stop() : player.play();
      },
      Icons.fast_forward: player.selectNextSection,
      Icons.skip_next: player.selectNextTrack,
    };

    return Container(
      color: Colors.black38,
      height: 74,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: options.entries
            .map(
              (option) => IconButton(
                  icon: Icon(
                    option.key,
                    size: 32,
                  ),
                  onPressed: option.value),
            )
            .toList(),
      ),
    );
  }
}

class _TrackList extends StatelessWidget with ListItemLongPressPopupMenu {
  final Setlist setlist;
  final NotifierSetlistPlayer player;
  final ItemScrollController scrollController;

  _TrackList(
    this.setlist,
    this.player, {
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification overscroll) {
        overscroll.disallowGlow();
        return true;
      },
      child: ScrollablePositionedList.separated(
        itemScrollController: scrollController,
        itemCount: setlist.tracksCount,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          final track = setlist.tracks[index];
          return InkWell(
            onTap: () {
              player.selectTrack(index);
            },
            onTapDown: storeTapPosition,
            onLongPress: () => showPopupMenu(
              context,
              index,
              _buildPopupMenuItems(context, setlist.id, setlist.tracks, player),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Text('${index + 1}.'),
              ),
              title: Text(
                '${track.name}',
                style: TextStyle(
                  color: player.currentTrackIndex == index
                      ? Theme.of(context).accentColor
                      : Colors.white,
                  fontWeight:
                      player.currentTrackIndex == index ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(track.isComplex ? 'Złożony' : '${track.settings.tempo} BPM'),
            ),
          );
        },
      ),
    );
  }

  dynamic _buildPopupMenuItems(
      BuildContext context, String setlistId, List<Track> tracks, SetlistPlayer player) {
    return [
      PopupMenuItem(
        child: Text('Edytuj'),
        value: (index) {
          if (!context.read(metronomeProvider).isPlaying) {
            Get.to(AddEditTrackScreen(setlistId, tracks[index]));
          } else {
            Get.snackbar('Zatrzymaj odtwarzanie', 'aby edytować utwór.', colorText: Colors.white);
          }
        },
      ),
      PopupMenuItem(
          child: Text('Usuń'),
          value: (index) {
            if (!context.read(metronomeProvider).isPlaying) {
              final setlistManager = context.read(setlistManagerProvider);

              setlistManager.deleteTrack(setlistId, index);

              if (setlistManager.getSetlist(setlistId).tracksCount == player.currentTrackIndex) {
                player.selectTrack(setlist.tracksCount - 1);
              }
            } else {
              Get.snackbar('Zatrzymaj odtwarzanie', 'aby usunąć utwór.', colorText: Colors.white);
            }
          }),
    ];
  }
}
