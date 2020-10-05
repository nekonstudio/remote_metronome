import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:metronom/models/track.dart';
import 'package:metronom/providers/setlists_manager.dart';
import 'package:metronom/widgets/metronome_panel.dart';
import 'package:provider/provider.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:toggle_switch/toggle_switch.dart';

class NewTrackScreen extends StatefulWidget {
  static const routePath = '/newTrack';

  static final _formKey = GlobalKey<FormState>();

  @override
  _NewTrackScreenState createState() => _NewTrackScreenState();
}

class _NewTrackScreenState extends State<NewTrackScreen> {
  static final _metronomeKey = GlobalKey<MetronomePanelState>();
  final _metronomePanel = MetronomePanel(key: _metronomeKey);
  bool _isComplexTrack = false;
  int _initialModeIndex = 0;
  String _setlistId;

  final List<Section> _sections = [];

  String _validate(String value) {
    if (value.isEmpty) {
      return 'To pole nie może być puste';
    }

    return null;
  }

  void _onSubmit(BuildContext context) {
    if (NewTrackScreen._formKey.currentState.validate()) {
      if (_isComplexTrack && _sections.isEmpty) {
        // Get.snackbar('title', 'message');
        Get.rawSnackbar(
            message: 'Dodaj sekcje lub przejdź na tryb "Prosty"',
            duration: Duration(milliseconds: 3000),
            animationDuration: Duration(milliseconds: 500));
        return;
      }
      NewTrackScreen._formKey.currentState.save();
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

    Provider.of<SetlistManager>(context, listen: false)
        .addTrack(_setlistId, track);

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

  @override
  Widget build(BuildContext context) {
    _setlistId = ModalRoute.of(context).settings.arguments as String;

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
      child: Scaffold(
        appBar: AppBar(
          title: Text('Nowy utwór'),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: NewTrackScreen._formKey,
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
                                _metronomePanel,
                              ],
                            ),
                          ),
                          // child: MetronomePanel(),
                        ),
                        if (_isComplexTrack)
                          Container(
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
                                          height: 60,
                                          child: Center(
                                            child: Text('Brak sekcji'),
                                          ),
                                        )
                                      : Container(
                                          height: (72 * _sections.length)
                                              .toDouble(),
                                          child: ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: _sections.length,
                                            itemBuilder: (context, index) =>
                                                Column(
                                              children: [
                                                ListTile(
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
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                if (index <
                                                    _sections.length - 1)
                                                  Divider(
                                                    height: 0,
                                                  ),
                                              ],
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
  _SectionForm(this.sectionHandler);

  static final _formKey = GlobalKey<FormState>();
  static final _metronomeKey = GlobalKey<MetronomePanelState>();
  MetronomePanel _metronomePanel = MetronomePanel(key: _metronomeKey);
  Section _section = Section();

  void _addSection(BuildContext context) {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    _section.tempo = _metronomeKey.currentState.currentTempo;
    _section.beatsPerBar = _metronomeKey.currentState.beatsPerBar;
    _section.clicksPerBeat = _metronomeKey.currentState.clicksPerBeat;

    sectionHandler(_section);

    // Navigator.of(context).pop();
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
              title: Text('Dodaj sekcję'),
            ),
          ),
          _metronomePanel,
          Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Nazwa',
                    ),
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      _section.title = value;
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
                          decoration: InputDecoration(
                            // contentPadding: EdgeInsets.zero,
                            labelText: 'Ilość taktów',
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: false, signed: false),
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                          onSaved: (value) {
                            _section.barsCount = int.parse(value);
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
                          child: Text('Dodaj'),
                          onPressed: () {
                            _addSection(context);
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
