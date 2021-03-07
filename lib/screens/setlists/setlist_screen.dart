import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:metronom/models/setlist.dart';
import 'package:metronom/providers/remote/device_synchronization_mode_notifier.dart';
import 'package:metronom/providers/remote/remote_command.dart';
import 'package:metronom/providers/remote/remote_synchronization.dart';
import 'package:metronom/providers/setlist_player/notifier_setlist_player.dart';
import 'package:metronom/providers/setlist_player/remote_synchronized_setlist_player.dart';
import 'package:metronom/providers/setlist_player/setlist_player.dart';
import 'package:metronom/providers/setlist_player/setlist_player_interface.dart';
import 'package:metronom/screens/track/track_screen.dart';
import 'package:metronom/widgets/remote_synchronized_screen.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../mixins/list_item_long_press_popup_menu.dart';
import '../../models/track.dart';
import '../../providers/metronome/metronome_base.dart';
import '../../providers/setlists_manager.dart';
import '../../widgets/metronome_track_panel.dart';
import 'add_edit_track_screen.dart';

class IsRemoteSetlistScreenNotifier extends StateNotifier<bool> {
  IsRemoteSetlistScreenNotifier(bool state) : super(state);

  void changeState(bool value) {
    if (value != state) state = value;
  }
}

final isRemoteSetlistScreenProvider = StateNotifierProvider(
  (ref) => IsRemoteSetlistScreenNotifier(false),
);

SetlistPlayer _setlistPlayerCopy;

final setlistPlayerProvider =
    ChangeNotifierProvider.autoDispose.family<NotifierSetlistPlayer, Setlist>(
  (ref, setlist) {
    final modeProvider = ref.watch(deviceSynchronizationModeNotifierProvider);
    final metronome = ref.watch(metronomeImplProvider);

    final impl = modeProvider.isSynchronized
        ? RemoteSynchronizedSetlistPlayer(ref.read(synchronizationProvider), setlist, metronome)
        : SetlistPlayer(setlist, metronome);

    if (_setlistPlayerCopy != null) {
      if (modeProvider.previousMode == DeviceSynchronizationMode.Host) {
        modeProvider.resetPreviousMode();
        impl.copy(_setlistPlayerCopy);
      }
    }

    _setlistPlayerCopy = impl;

    return NotifierSetlistPlayer(impl);
  },
);

class SetlistScreen extends RemoteSynchronizedScreen {
  final Setlist setlist;

  SetlistScreen(this.setlist);

  ItemScrollController _scrollController = ItemScrollController();

  @override
  void initSynchronization(BuildContext context, RemoteSynchronization synchronization) {
    Future.delayed(
      Duration(milliseconds: 50),
      () => context.read(isRemoteSetlistScreenProvider).changeState(true),
    );

    synchronization.broadcastRemoteCommand(
      RemoteCommand.setSetlist(setlist),
    );
  }

  @override
  Widget buildTitle(BuildContext context) {
    return Consumer(
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
              Get.to(TrackScreen(setlistId: setlist.id));
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
    context.read(isRemoteSetlistScreenProvider).changeState(false);

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
  final SetlistPlayerInterface player;

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

class _TrackList extends StatefulWidget {
  final Setlist setlist;
  final NotifierSetlistPlayer player;
  final ItemScrollController scrollController;

  _TrackList(
    this.setlist,
    this.player, {
    this.scrollController,
  });

  @override
  __TrackListState createState() => __TrackListState();
}

class __TrackListState extends State<_TrackList> with ListItemLongPressPopupMenu {
  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification overscroll) {
        overscroll.disallowGlow();
        return true;
      },
      child: ScrollablePositionedList.separated(
        itemScrollController: widget.scrollController,
        itemCount: widget.setlist.tracksCount,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          final track = widget.setlist.tracks[index];
          return InkWell(
            onTap: () {
              widget.player.selectTrack(index);
            },
            onTapDown: storeTapPosition,
            onLongPress: () => showPopupMenu(
              context,
              index,
              _buildPopupMenuItems(
                  context, widget.setlist.id, widget.setlist.tracks, widget.player),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Text('${index + 1}.'),
              ),
              title: Text(
                '${track.name}',
                style: TextStyle(
                  color: widget.player.currentTrackIndex == index
                      ? Theme.of(context).accentColor
                      : Colors.white,
                  fontWeight: widget.player.currentTrackIndex == index
                      ? FontWeight.bold
                      : FontWeight.normal,
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
      BuildContext context, String setlistId, List<Track> tracks, SetlistPlayerInterface player) {
    return [
      PopupMenuItem(
        child: Text('Edytuj'),
        value: (index) {
          player.stop();
          Get.to(TrackScreen(setlistId: setlistId, track: tracks[index]));
        },
      ),
      PopupMenuItem(
          child: Text('Usuń'),
          value: (index) {
            player.stop();

            final setlistManager = context.read(setlistManagerProvider);
            setlistManager.deleteTrack(setlistId, index);

            final tracksCount = setlistManager.getSetlist(setlistId).tracksCount;
            final nextTrackIndex = tracksCount - 1;
            if (tracksCount == player.currentTrackIndex && nextTrackIndex >= 0) {
              player.selectTrack(nextTrackIndex);
            } else {
              player.update();
            }
          }),
    ];
  }
}
