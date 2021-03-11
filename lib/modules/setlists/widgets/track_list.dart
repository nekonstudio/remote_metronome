import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../utils/mixins/list_item_long_press_popup_menu.dart';
import '../logic/setlist_player/notifier_setlist_player.dart';
import '../logic/setlist_player/setlist_player_interface.dart';
import '../models/setlist.dart';
import '../models/track.dart';
import '../providers/setlist_manager_provider.dart';
import '../screens/track_screen.dart';

class TrackList extends StatefulWidget {
  final Setlist setlist;
  final NotifierSetlistPlayer player;
  final ItemScrollController scrollController;

  TrackList(
    this.setlist,
    this.player, {
    this.scrollController,
  });

  @override
  _TrackListState createState() => _TrackListState();
}

class _TrackListState extends State<TrackList> with ListItemLongPressPopupMenu {
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
