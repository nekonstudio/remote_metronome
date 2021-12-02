import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../widgets/popup_menu_list_item.dart';
import '../logic/setlist_player/notifier_setlist_player.dart';
import '../logic/setlist_player/setlist_player_interface.dart';
import '../models/setlist.dart';
import '../models/track.dart';
import '../providers/setlist_manager_provider.dart';
import '../screens/track_screen.dart';

class TrackList extends ConsumerWidget {
  final Setlist setlist;
  final NotifierSetlistPlayer player;
  final ItemScrollController scrollController;

  TrackList(
    this.setlist,
    this.player, {
    this.scrollController,
  });

  Widget build(BuildContext context, WidgetRef ref) {
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
          return PopupMenuListItem(
            index: index,
            popupMenuEntries:
                _buildPopupMenuItems(ref, setlist.id, setlist.tracks, player),
            onPressed: () => player.selectTrack(index),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Text('${index + 1}.'),
              ),
              title: Text(
                '${track.name}',
                style: TextStyle(
                  color: player.currentTrackIndex == index
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.white,
                  fontWeight: player.currentTrackIndex == index
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                  track.isComplex ? 'Złożony' : '${track.settings.tempo} BPM'),
            ),
          );
        },
      ),
    );
  }

  dynamic _buildPopupMenuItems(WidgetRef ref, String setlistId,
      List<Track> tracks, SetlistPlayerInterface player) {
    return [
      PopupMenuItem(
        child: Text('Edytuj'),
        value: (index) {
          player.stop();
          Get.to(() => TrackScreen(setlistId: setlistId, track: tracks[index]));
        },
      ),
      PopupMenuItem(
        child: Text('Usuń'),
        value: (index) {
          player.stop();

          final setlistManager = ref.read(setlistManagerProvider);
          setlistManager.deleteTrack(setlistId, index);

          final tracksCount = setlistManager.getSetlist(setlistId).tracksCount;
          final nextTrackIndex = tracksCount - 1;
          if (tracksCount == player.currentTrackIndex && nextTrackIndex >= 0) {
            player.selectTrack(nextTrackIndex);
          } else {
            player.update();
          }
        },
      ),
    ];
  }
}
