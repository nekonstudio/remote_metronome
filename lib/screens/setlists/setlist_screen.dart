import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../mixins/list_item_long_press_popup_menu.dart';
import '../../models/track.dart';
import '../../providers/metronome/metronome.dart';
import '../../providers/setlist_player.dart';
import '../../providers/setlists_manager.dart';
import '../../widgets/play_complex_track_panel.dart';
import '../../widgets/play_simple_track_panel.dart';
import '../../widgets/remote_mode_screen.dart';
import 'add_edit_track_screen.dart';

class SetlistScreen extends ConsumerWidget with ListItemLongPressPopupMenu {
  static const routePath = '/setlist';
  static const int SCROLL_DURATION = 300;

  ItemScrollController _scrollController = ItemScrollController();

  dynamic _buildPopupMenuItems(
      BuildContext context, String setlistId, List<Track> tracks) {
    return [
      PopupMenuItem(
        child: Text('Edytuj'),
        value: (index) {
          if (!context.read(metronomeProvider).isPlaying) {
            Get.to(AddEditTrackScreen(setlistId, tracks[index]));
          } else {
            Get.snackbar('Zatrzymaj odtwarzanie', 'aby edytować utwór.',
                colorText: Colors.white);
          }
        },
      ),
      PopupMenuItem(
          child: Text('Usuń'),
          value: (index) {
            if (!context.read(metronomeProvider).isPlaying) {
              context
                  .read(setlistManagerProvider)
                  .deleteTrack(setlistId, index);
            } else {
              Get.snackbar('Zatrzymaj odtwarzanie', 'aby usunąć utwór.',
                  colorText: Colors.white);
            }
          }),
    ];
  }

  void onTrackChanged(int currentIndex) {
    _scrollController.scrollTo(
        index: currentIndex, duration: Duration(milliseconds: SCROLL_DURATION));
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final setlistId = ModalRoute.of(context).settings.arguments as String;
    final setlist = watch(setlistManagerProvider).getSetlist(setlistId);
    final tracks = setlist.tracks;

    final player = watch(setlistPlayerProvider);
    player.update(tracks);
    player.onTrackChangedCallback =
        () => onTrackChanged(player.currentTrackIndex);

    final selectedTrack = player.currentTrack;

    return RemoteModeScreen(
      title: tracks.length == 0
          ? Text(setlist.name)
          : ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                selectedTrack.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(setlist.name),
            ),
      body: tracks.length == 0
          ? Center(
              child: Text('Brak utworów w setliście'),
            )
          : Container(
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
                              ? PlayComplexTrackPanel()
                              : PlaySimpleTrackPanel(selectedTrack),
                        ),
                      ],
                    ),
                  ),
                  _PlayPanel(player),
                  Expanded(
                    flex: 6,
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                      onNotification:
                          (OverscrollIndicatorNotification overscroll) {
                        overscroll.disallowGlow();
                        return true;
                      },
                      child: ScrollablePositionedList.builder(
                        itemScrollController: _scrollController,
                        itemCount: setlist.tracksCount,
                        itemBuilder: (context, index) {
                          final track = tracks[index];
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  player.currentTrackIndex = index;
                                },
                                onTapDown: storeTapPosition,
                                onLongPress: () => showPopupMenu(
                                  context,
                                  index,
                                  _buildPopupMenuItems(
                                      context, setlistId, tracks),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      child: Text('${index + 1}.')),
                                  title: Text(
                                    '${track.name}',
                                    style: TextStyle(
                                      color: player.currentTrackIndex == index
                                          ? Theme.of(context).accentColor
                                          : Colors.white,
                                      fontWeight:
                                          player.currentTrackIndex == index
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Text(track.isComplex
                                      ? 'Złożony'
                                      : '${track.tempo} BPM'),
                                ),
                              ),
                              if (index < setlist.tracksCount - 1)
                                Divider(
                                  height: 0,
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: Consumer(
        builder: (context, watch, child) {
          final isPlaying = watch(metronomeProvider).isPlaying;
          return FloatingActionButton(
            backgroundColor:
                isPlaying ? Colors.grey : Theme.of(context).accentColor,
            child: Icon(Icons.add),
            onPressed: () {
              if (!isPlaying) {
                Get.to(AddEditTrackScreen(setlist.id, null));
              }
            },
          );
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: tracks.length == 0
            ? Text(setlist.name)
            : ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  selectedTrack.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(setlist.name),
              ),
      ),
      body: tracks.length == 0
          ? Center(
              child: Text('Brak utworów w setliście'),
            )
          : Container(
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
                              ? PlayComplexTrackPanel()
                              : PlaySimpleTrackPanel(selectedTrack),
                        ),
                      ],
                    ),
                  ),
                  _PlayPanel(player),
                  Expanded(
                    flex: 6,
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                      onNotification:
                          (OverscrollIndicatorNotification overscroll) {
                        overscroll.disallowGlow();
                        return true;
                      },
                      child: ScrollablePositionedList.builder(
                        itemScrollController: _scrollController,
                        itemCount: setlist.tracksCount,
                        itemBuilder: (context, index) {
                          final track = tracks[index];
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  player.currentTrackIndex = index;
                                },
                                onTapDown: storeTapPosition,
                                onLongPress: () => showPopupMenu(
                                  context,
                                  index,
                                  _buildPopupMenuItems(
                                      context, setlistId, tracks),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      child: Text('${index + 1}.')),
                                  title: Text(
                                    '${track.name}',
                                    style: TextStyle(
                                      color: player.currentTrackIndex == index
                                          ? Theme.of(context).accentColor
                                          : Colors.white,
                                      fontWeight:
                                          player.currentTrackIndex == index
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Text(track.isComplex
                                      ? 'Złożony'
                                      : '${track.tempo} BPM'),
                                ),
                              ),
                              if (index < setlist.tracksCount - 1)
                                Divider(
                                  height: 0,
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: Consumer(
        builder: (context, watch, child) {
          final isPlaying = watch(metronomeProvider).isPlaying;
          return FloatingActionButton(
            backgroundColor:
                isPlaying ? Colors.grey : Theme.of(context).accentColor,
            child: Icon(Icons.add),
            onPressed: () {
              if (!isPlaying) {
                Get.to(AddEditTrackScreen(setlist.id, null));
              }
            },
          );
        },
      ),
    );
  }
}

class _PlayPanel extends StatelessWidget {
  final SetlistPlayer player;

  _PlayPanel(this.player);

  @override
  Widget build(BuildContext context) {
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
              .map((option) => IconButton(
                  icon: Icon(
                    option.key,
                    size: 32,
                  ),
                  onPressed: option.value))
              .toList()),
    );
  }
}

// class _AddTrackPanel extends StatelessWidget {
//   final SetlistManager setlistsManager;
//   final String setlistId;
//   _AddTrackPanel(
//     this.setlistsManager,
//     this.setlistId,
//   );

//   static final _formKey = GlobalKey<FormState>();

//   String _validate(String value) {
//     if (value.isEmpty) {
//       return 'Wprowadź nazwę';
//     }

//     return null;
//   }

//   void _onSubmit() {
//     if (_formKey.currentState.validate()) {
//       _formKey.currentState.save();
//     }
//   }

//   void _save(BuildContext context, String value) {
//     // setlistsManager.addTrack(setlistId, value);
//     Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Container(
//         height: MediaQuery.of(context).viewInsets.bottom + 230,
//         child: Column(
//           children: [
//             Container(
//               color: Colors.black26,
//               child: ListTile(
//                 leading: Icon(Icons.queue_music),
//                 title: Text('Nowy utwór'),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   TextFormField(
//                     decoration: InputDecoration(labelText: 'Nazwa'),
//                     autofocus: true,
//                     validator: _validate,
//                     onFieldSubmitted: (_) {
//                       _onSubmit();
//                     },
//                     onSaved: (value) {
//                       _save(context, value);
//                     },
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   RaisedButton(
//                     child: Text('Dodaj'),
//                     onPressed: _onSubmit,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }