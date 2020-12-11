import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../models/track.dart';
import '../providers/setlists_manager.dart';
import '../widgets/metronome_panel.dart';
import '../widgets/remote_mode_screen.dart';

class AddEditTrackScreen extends StatefulWidget {
  static const routePath = '/newTrack';

  static final _formKey = GlobalKey<FormState>();

  final String setlistId;
  final Track track;

  AddEditTrackScreen(this.setlistId, this.track);

  @override
  _AddEditTrackScreenState createState() => _AddEditTrackScreenState();
}

class _AddEditTrackScreenState extends State<AddEditTrackScreen> {
  static final _metronomeKey = GlobalKey<MetronomePanelState>();
  final _metronomePanel = MetronomePanel(key: _metronomeKey);
  bool _isComplexTrack = false;
  int _initialModeIndex = 0;
  String _setlistId;
  Track _track;
  bool _isEditingMode = false;

  List<Section> _sections = [];

  @override
  void initState() {
    super.initState();

    _setlistId = widget.setlistId;
    _track = widget.track;

    if (_track != null) {
      _isEditingMode = true;
      _isComplexTrack = _track.isComplex;
      _initialModeIndex = _isComplexTrack ? 1 : 0;
      if (_isComplexTrack) _sections = _track.sections;
    }
  }

  String _validate(String value) {
    if (value.isEmpty) {
      return 'To pole nie może być puste';
    }

    return null;
  }

  void _onSubmit(BuildContext context) {
    if (AddEditTrackScreen._formKey.currentState.validate()) {
      if (_isComplexTrack && _sections.isEmpty) {
        // Get.snackbar('title', 'message');
        Get.rawSnackbar(
            message: 'Dodaj sekcje lub przejdź na tryb "Prosty"',
            duration: Duration(milliseconds: 3000),
            animationDuration: Duration(milliseconds: 500));
        return;
      }
      AddEditTrackScreen._formKey.currentState.save();
    }
  }

  void _save(BuildContext context, String value) {
    Track track = _isComplexTrack
        ? Track.complex(value, _sections)
        : Track.simple(
            value,
            _metronomeKey.currentState.currentTempo,
            _metronomeKey.currentState.beatsPerBar,
            _metronomeKey.currentState.clicksPerBeat,
          );

    final setlistManager = context.read(setlistManagerProvider);

    if (_isEditingMode) {
      setlistManager.editTrack(_setlistId, _track.id, track);
    } else {
      setlistManager.addTrack(_setlistId, track);
    }

    Get.back();
  }

  void _toggleMode(int index) {
    setState(() {
      _isComplexTrack = index == 0 ? false : true;
      _initialModeIndex = index;
    });
  }

  void _addSection(Section section) {
    setState(() {
      _sections.add(section);
    });
  }

  void _editSection(Section oldSection, Section newSection) {
    final index = _sections.indexOf(oldSection);
    setState(() {
      _sections[index] = newSection;
    });
  }

  void _deleteSection(Section section) {
    setState(() {
      _sections.remove(section);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SwipeDetector(
      onSwipeRight: () {
        if (_isComplexTrack) {
          setState(() {
            _isComplexTrack = false;
            _initialModeIndex = 0;
          });
        }
      },
      onSwipeLeft: () {
        if (!_isComplexTrack) {
          setState(() {
            _isComplexTrack = true;
            _initialModeIndex = 1;
          });
        }
      },
      child: RemoteModeScreen(
        title: Text(_isEditingMode ? 'Edycja utworu' : 'Nowy utwór'),
        body: SingleChildScrollView(
          child: Form(
            key: AddEditTrackScreen._formKey,
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ToggleSwitch(
                          initialLabelIndex: _initialModeIndex,
                          onToggle: _toggleMode,
                          labels: ['Prosty', 'Złożony'],
                          minWidth: 150,
                          activeBgColor: Theme.of(context).accentColor,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Nazwa'),
                          initialValue: _isEditingMode ? _track.name : '',
                          autofocus: true,
                          validator: _validate,
                          onFieldSubmitted: (_) {
                            _onSubmit(context);
                          },
                          onSaved: (value) {
                            _save(context, value);
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Visibility(
                          maintainState: true,
                          visible: !_isComplexTrack,
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(10))),
                                  child: ListTile(
                                    title: Text('Wybierz tempo'),
                                  ),
                                ),
                                _isEditingMode
                                    ? _isComplexTrack
                                        ? _metronomePanel
                                        : _metronomePanel.setup(
                                            _track.tempo,
                                            _track.beatsPerBar,
                                            _track.clicksPerBeat)
                                    : _metronomePanel,
                              ],
                            ),
                          ),
                          // child: MetronomePanel(),
                        ),
                        if (_isComplexTrack)
                          Container(
                              decoration: BoxDecoration(
                                  // color: Colors.black26,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(10))),
                                    child: ListTile(
                                      title: Text('Sekcje utworu'),
                                      // subtitle: FittedBox(
                                      //   child: Text(
                                      //       'Użyj przycisku obok, aby dodać nową sekcję'),
                                      // ),
                                      trailing: IconButton(
                                          padding: EdgeInsets.zero,
                                          splashRadius: 25,
                                          icon: Icon(
                                            Icons.add_circle,
                                            size: 35,
                                          ),
                                          onPressed: () {
                                            showModalBottomSheet(
                                                isScrollControlled: true,
                                                context: context,
                                                builder: (_) =>
                                                    _SectionForm(_addSection));
                                          }),
                                    ),
                                  ),
                                  _sections.length == 0
                                      ? Container(
                                          color: Color.fromRGBO(36, 36, 36, 1),
                                          height: 60,
                                          child: Center(
                                            child: Text('Brak sekcji'),
                                          ),
                                        )
                                      : Container(
                                          height: (72 * _sections.length)
                                              .toDouble(),
                                          child: ClipRect(
                                            child: ListView.separated(
                                              separatorBuilder: (_, __) =>
                                                  Divider(
                                                height: 0,
                                              ),
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: _sections.length,
                                              itemBuilder: (context, index) =>
                                                  Slidable(
                                                actionPane:
                                                    SlidableScrollActionPane(),
                                                actionExtentRatio: 0.2,
                                                child: Container(
                                                  color: Color.fromRGBO(
                                                      36, 36, 36, 1),
                                                  child: ListTile(
                                                    leading: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      child:
                                                          Text('${index + 1}.'),
                                                    ),
                                                    title: Text(
                                                        _sections[index].title),
                                                    subtitle: Text(
                                                        '${_sections[index].tempo} BPM'),
                                                    trailing: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      child: Text(
                                                        'x${_sections[index].barsCount}',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                secondaryActions: [
                                                  IconSlideAction(
                                                    caption: 'Edytuj',
                                                    color: Colors.blue,
                                                    icon: Icons.edit,
                                                    onTap: () {
                                                      showModalBottomSheet(
                                                          isScrollControlled:
                                                              true,
                                                          context: context,
                                                          builder: (_) =>
                                                              _SectionForm(
                                                                _editSection,
                                                                existingSection:
                                                                    _sections[
                                                                        index],
                                                              ));
                                                    },
                                                  ),
                                                  IconSlideAction(
                                                    caption: 'Usuń',
                                                    color: Colors.red,
                                                    icon: Icons.delete,
                                                    onTap: () => _deleteSection(
                                                        _sections[index]),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                ],
                              )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.done),
          onPressed: () => _onSubmit(context),
        ),
      ),
    );
  }
}

class _SectionForm extends StatelessWidget {
  final Function sectionHandler;
  final Section existingSection;
  _SectionForm(this.sectionHandler, {this.existingSection});

  static final _formKey = GlobalKey<FormState>();
  static final _metronomeKey = GlobalKey<MetronomePanelState>();
  MetronomePanel _metronomePanel = MetronomePanel(key: _metronomeKey);
  Section _newSection = Section();

  void _saveForm(BuildContext context) {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    _newSection.tempo = _metronomeKey.currentState.currentTempo;
    _newSection.beatsPerBar = _metronomeKey.currentState.beatsPerBar;
    _newSection.clicksPerBeat = _metronomeKey.currentState.clicksPerBeat;

    if (existingSection == null) {
      sectionHandler(_newSection);
    } else {
      sectionHandler(existingSection, _newSection);
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).viewInsets.bottom + 440,
      child: Column(
        children: [
          Container(
            color: Colors.black26,
            child: ListTile(
              leading: Icon(Icons.playlist_add),
              title: Text(
                  existingSection == null ? 'Dodaj sekcję' : 'Edytuj sekcję'),
            ),
          ),
          existingSection != null
              ? _metronomePanel.setup(existingSection.tempo,
                  existingSection.beatsPerBar, existingSection.clicksPerBeat)
              : _metronomePanel,
          Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  TextFormField(
                    autofocus: true,
                    initialValue:
                        existingSection == null ? '' : existingSection.title,
                    decoration: InputDecoration(
                      labelText: 'Nazwa',
                    ),
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      _newSection.title = value;
                    },
                    validator: (text) {
                      if (text.isEmpty) {
                        return 'To pole nie może być puste';
                      }

                      return null;
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: existingSection == null
                              ? ''
                              : existingSection.barsCount.toString(),
                          decoration: InputDecoration(
                            // contentPadding: EdgeInsets.zero,
                            labelText: 'Ilość taktów',
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: false, signed: false),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onSaved: (value) {
                            _newSection.barsCount = int.parse(value);
                          },
                          validator: (text) {
                            if (text.isEmpty) {
                              return 'To pole nie może być puste';
                            }
                            if (int.parse(text) <= 0) {
                              return 'To pole musi mieć wartość większą od 0';
                            }

                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 23, left: 20),
                        child: RaisedButton(
                          child:
                              Text(existingSection == null ? 'Dodaj' : 'Zmień'),
                          onPressed: () {
                            _saveForm(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
