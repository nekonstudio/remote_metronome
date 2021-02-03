import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:metronom/models/setlist.dart';
import 'package:metronom/providers/remote/device_synchronization_mode_notifier.dart';
import 'package:metronom/providers/remote/remote_command.dart';
import 'package:metronom/providers/remote/remote_synchronization.dart';
import 'package:metronom/providers/setlist_player/notifier_setlist_player.dart';
import 'package:metronom/providers/setlist_player/remote_synchronized_notifier_setlist_player.dart';
import 'package:metronom/providers/setlist_player/setlist_player.dart';
import 'package:metronom/widgets/remote_synchronized_screen.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../mixins/list_item_long_press_popup_menu.dart';
import '../../models/track.dart';
import '../../providers/metronome/metronome_base.dart';
import '../../providers/setlists_manager.dart';
import '../../widgets/metronome_track_panel.dart';
import 'add_edit_track_screen.dart';

final setlistPlayerProvider =
    ChangeNotifierProvider.autoDispose.family<NotifierSetlistPlayer, Setlist>(
  (ref, setlist) =>
      ref.watch(deviceSynchronizationModeNotifierProvider).mode == DeviceSynchronizationMode.Host
          ? RemoteSynchronizedNotifierSetlistPlayer(ref.read(synchronizationProvider), setlist)
          : NotifierSetlistPlayer(setlist),
);

class SetlistScreen extends RemoteSynchronizedScreen {
  final Setlist setlist;

  SetlistScreen(this.setlist);

  ItemScrollController _scrollController = ItemScrollController();

  @override
  void initSynchronization(BuildContext context, RemoteSynchronization synchronization) {
    synchronization.broadcastRemoteCommand(
      RemoteCommand.setSetlist(setlist),
    );
  }

  @override
  Widget buildTitle(BuildContext context) {
    if (!setlist.hasTracks) {
      return Text(setlist.name);
    }

    final player = context.read(setlistPlayerProvider(setlist));
    final selectedTrack = player.currentTrack;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        selectedTrack.name,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(setlist.name),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        watch(setlistManagerProvider);

        final player = watch(setlistPlayerProvider(setlist));
        player.onTrackChanged = _onTrackChanged;

        return setlist.hasTracks ? _buildSetlist(player) : _buildEmptySetlist();
      },
    );
  }

  @override
  Widget buildFloatingActionButton(BuildContext context) {
    return Consumer(
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
  }

  @override
  Future<bool> onScreenClosing(BuildContext context, RemoteSynchronization synchronization) {
    if (synchronization.synchronizationMode.isSynchronized) {
      synchronization.broadcastRemoteCommand(
        RemoteCommand.stopTrack(),
      );

      final metronomeSettings = synchronization.simpleMetronomeSettingsGetter();
      synchronization.broadcastRemoteCommand(
        RemoteCommand.setMetronomeSettings(metronomeSettings),
      );
    }
    context.read(setlistPlayerProvider(setlist)).stop();

    return Future.value(true);
  }

  Widget _buildSetlist(NotifierSetlistPlayer player) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Expanded(flex: 4, child: MetronomeTrackPanel(player)),
          _PlayerPanel(player),
          Expanded(
            flex: 6,
            child: _TrackList(setlist, player, scrollController: _scrollController),
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
