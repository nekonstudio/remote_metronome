import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metronom/mixins/list_item_long_press_popup_menu.dart';
import 'package:metronom/widgets/play_complex_track_panel.dart';
import 'package:metronom/widgets/play_simple_track_panel.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../models/track.dart';
import '../providers/metronome.dart';
import '../providers/setlists_manager.dart';
import '../widgets/visualization.dart';
import 'add_edit_track_screen.dart';

class SetlistScreen extends StatefulWidget {
  static const routePath = '/setlist';

  @override
  _SetlistScreenState createState() => _SetlistScreenState();
}

class _SetlistScreenState extends State<SetlistScreen>
    with ListItemLongPressPopupMenu {
  Metronome _metronome;
  SetlistManager _setlistManager;
  String _setlistId;
  List<Track> _tracks;
  int _selectedTrackIndex = 0;
  Track _selectedTrack;
  ItemScrollController _scrollController = ItemScrollController();
  static const int SCROLL_DURATION = 300;
  // var _tapPosition;

  @override
  void dispose() {
    _metronome.terminate();
    super.dispose();
  }

  void _selectPreviousTrack() {
    if (_selectedTrackIndex > 0) {
      setState(() {
        _selectedTrackIndex--;
      });

      _metronome.stop();
      _scrollController.scrollTo(
          index: _selectedTrackIndex,
          duration: Duration(milliseconds: SCROLL_DURATION));
    }
  }

  void _selectNextTrack() {
    if (_selectedTrackIndex < _tracks.length - 1) {
      setState(() {
        _selectedTrackIndex++;
      });

      _metronome.stop();
      _scrollController.scrollTo(
          index: _selectedTrackIndex,
          duration: Duration(milliseconds: SCROLL_DURATION));
    }
  }

  void _selectNextTrackSection() {
    if (_selectedTrack.isComplex) {
      if (_selectedTrack.currentSectionIndex <
          _selectedTrack.sections.length - 1) {
        _selectedTrack.selectNextSection();
        _changeMetronomForCurrentSection();
      }
    }
  }

  void _selectPreviousTrackSection() {
    if (_selectedTrack.isComplex) {
      if (_selectedTrack.currentSectionIndex > 0) {
        _selectedTrack.selectPreviousSection();
        _changeMetronomForCurrentSection();
      }
    }
  }

  void _changeMetronomForCurrentSection() {
    final currentSection = _selectedTrack.currentSection;
    // _metronome.change(currentSection.tempo, false,
    //     beatsPerBar: currentSection.beatsPerBar,
    //     clicksPerBeat: currentSection.clicksPerBeat);

    // _metronome.change(
    //     tempo: currentSection.tempo,
    //     beatsPerBar: currentSection.beatsPerBar,
    //     clicksPerBeat: currentSection.clicksPerBeat,
    //     play: false);
  }

  dynamic _buildPopupMenuItems() {
    return [
      PopupMenuItem(
        child: Text('Edytuj'),
        value: (index) {
          if (!_metronome.isPlaying) {
            Get.to(AddEditTrackScreen(_setlistId, _tracks[index]));
          } else {
            Get.snackbar('Zatrzymaj odtwarzanie', 'aby edytować utwór.',
                colorText: Colors.white);
          }
        },
      ),
      PopupMenuItem(
          child: Text('Usuń'),
          value: (index) {
            if (!_metronome.isPlaying) {
              _setlistManager.deleteTrack(_setlistId, index);
            } else {
              Get.snackbar('Zatrzymaj odtwarzanie', 'aby usunąć utwór.',
                  colorText: Colors.white);
            }
          }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _setlistId = ModalRoute.of(context).settings.arguments as String;
    _setlistManager = Provider.of<SetlistManager>(context);
    final setlist = _setlistManager.getSetlist(_setlistId);
    _tracks = setlist.tracks;
    _selectedTrack = _tracks.length > 0 ? _tracks[_selectedTrackIndex] : null;
    _metronome = Provider.of<Metronome>(context);

    if (_selectedTrack != null) {
      final tempo = _selectedTrack.isComplex
          ? _selectedTrack.sections.first.tempo
          : _selectedTrack.tempo;

      final beatsPerBar = _selectedTrack.isComplex
          ? _selectedTrack.sections.first.beatsPerBar
          : _selectedTrack.beatsPerBar;

      final clicksPerBeat = _selectedTrack.isComplex
          ? _selectedTrack.sections.first.clicksPerBeat
          : _selectedTrack.clicksPerBeat;

      _metronome.setup(tempo,
          beatsPerBar: beatsPerBar, clicksPerBeat: clicksPerBeat);
    }

    return Scaffold(
      appBar: AppBar(
        title: _tracks.length == 0
            ? Text(setlist.name)
            : ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _selectedTrack.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(setlist.name),
              ),
      ),
      body: _tracks.length == 0
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
                            child: _selectedTrack.isComplex
                                ? ChangeNotifierProvider.value(
                                    value: _selectedTrack,
                                    child: PlayComplexTrackPanel(
                                        _metronome, _selectNextTrack),
                                  )
                                : PlaySimpleTrackPanel(
                                    _selectedTrack, _metronome)),
                      ],
                    ),
                  ),
                  _PlayPanel({
                    'previous': _selectPreviousTrack,
                    'rewind': _selectPreviousTrackSection,
                    'forward': _selectNextTrackSection,
                    'next': _selectNextTrack,
                  }),
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
                          final track = _tracks[index];
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedTrackIndex = index;
                                  });
                                  _metronome.stop();
                                },
                                onTapDown: storeTapPosition,
                                onLongPress: () => showPopupMenu(
                                    context, index, _buildPopupMenuItems()),
                                child: ListTile(
                                  leading: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      child: Text('${index + 1}.')),
                                  title: Text(
                                    '${track.name}',
                                    style: TextStyle(
                                      color: _selectedTrackIndex == index
                                          ? Theme.of(context).accentColor
                                          : Colors.white,
                                      fontWeight: _selectedTrackIndex == index
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
      floatingActionButton: FloatingActionButton(
        backgroundColor:
            _metronome.isPlaying ? Colors.grey : Theme.of(context).accentColor,
        child: Icon(Icons.add),
        onPressed: () {
          if (!_metronome.isPlaying) {
            Get.to(AddEditTrackScreen(setlist.id, null));
          }
        },
      ),
    );
  }
}

class _PlayPanel extends StatefulWidget {
  final Map<String, Function> handlers;
  _PlayPanel(this.handlers);

  @override
  _PlayPanelState createState() => _PlayPanelState();
}

class _PlayPanelState extends State<_PlayPanel> {
  @override
  Widget build(BuildContext context) {
    final metronome = Provider.of<Metronome>(context);
    final Map<IconData, Function> options = {
      Icons.skip_previous: widget.handlers['previous'],
      Icons.fast_rewind: widget.handlers['rewind'],
      // metronome.isPlaying ? Icons.stop : Icons.play_arrow: () {
      //   metronome.isPlaying ? metronome.stop() : metronome.start();
      // },
      Icons.fast_forward: widget.handlers['forward'],
      Icons.skip_next: widget.handlers['next'],
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
