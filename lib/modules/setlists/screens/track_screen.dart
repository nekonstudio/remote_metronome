import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../metronome/controllers/metronome_settings_controller.dart';
import '../../metronome/models/metronome_settings.dart';
import '../../remote_synchronization/widgets/remote_mode_screen.dart';
import '../models/section.dart';
import '../models/track.dart';
import '../providers/setlist_manager_provider.dart';
import '../providers/setlist_player_provider.dart';
import '../widgets/complex_track_screen_body.dart';
import '../widgets/simple_track_screen_body.dart';

class TrackScreen extends StatefulWidget {
  final String setlistId;
  final Track track;

  const TrackScreen({Key key, @required this.setlistId, this.track})
      : super(key: key);

  @override
  _TrackScreenState createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isComplexTrack;
  int _screenModeSwitchIndex;
  List<Section> _trackSections;
  MetronomeSettingsController _settingsController;

  @override
  void initState() {
    super.initState();

    _isComplexTrack = widget.track?.isComplex ?? false;
    _screenModeSwitchIndex = _isComplexTrack ? 1 : 0;
    _trackSections = widget.track?.sections ?? [];
    final initialSettings = widget.track?.settings ?? MetronomeSettings();
    _settingsController =
        MetronomeSettingsController(initialSettings: initialSettings);
  }

  @override
  Widget build(BuildContext context) {
    return RemoteModeScreen(
      title: Text(widget.track == null ? 'Nowy utwór' : 'Edycja utworu'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ToggleSwitch(
                initialLabelIndex: _screenModeSwitchIndex,
                onToggle: _toggleMode,
                labels: ['Prosty', 'Złożony'],
                minWidth: 150,
                activeBgColor: [Theme.of(context).colorScheme.secondary],
                totalSwitches: 2,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        return TextFormField(
                          decoration: InputDecoration(labelText: 'Nazwa'),
                          initialValue: widget.track?.name ?? '',
                          autofocus: true,
                          validator: (value) => value.isEmpty
                              ? 'To pole nie może być puste'
                              : null,
                          onFieldSubmitted: (_) => _submitForm(),
                          onSaved: (value) => _saveForm(ref, value),
                        );
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _isComplexTrack
                        ? ComplexTrackScreenBody(_trackSections)
                        : SimpleTrackScreenBody(_settingsController),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done),
        onPressed: _submitForm,
      ),
    );
  }

  void _toggleMode(int index) {
    setState(() {
      _isComplexTrack = index == 0 ? false : true;
      _screenModeSwitchIndex = index;
    });
  }

  void _submitForm() {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      if (_isComplexTrack && _trackSections.isEmpty) {
        Get.rawSnackbar(
          message: 'Dodaj sekcje lub przejdź na tryb "Prosty"',
          duration: Duration(milliseconds: 3000),
          animationDuration: Duration(milliseconds: 500),
        );
      } else {
        formState.save();
      }
    }
  }

  void _saveForm(WidgetRef ref, String newTrackTitle) {
    final setlistId = widget.setlistId;
    final setlistManager = ref.read(setlistManagerProvider);
    final setlist = setlistManager.getSetlist(setlistId);
    final setlistPlayer = ref.read(setlistPlayerProvider(setlist));
    final newTrack = _isComplexTrack
        ? Track.complex(newTrackTitle, _trackSections)
        : Track.simple(newTrackTitle, _settingsController.value);

    widget.track == null
        ? setlistManager.addTrack(setlistId, newTrack)
        : setlistManager.editTrack(setlistId, widget.track.id, newTrack);
    setlistPlayer.update();

    Get.back();
  }
}
