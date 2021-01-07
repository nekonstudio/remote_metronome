import 'dart:async';

import 'package:metronom/models/track.dart';
import 'package:metronom/providers/metronome/metronome.dart';
import 'package:metronom/providers/metronome/metronome_settings.dart';
import 'package:metronom/providers/setlist_player/track_player.dart';

class ComplexTrackPlayer extends TrackPlayer {
  ComplexTrackPlayer(Track track) : super(track) {
    assert(track.isComplex == true);

    print('ComplexTrackPlayer(${track.name})');
  }

  int _currentSectionIndex = 0;
  int _currentSectionBar = 1;
  int _previousBarBeat = 1;
  StreamSubscription<dynamic> _sub;

  Section get _currentSection => track.sections[_currentSectionIndex];

  @override
  int get currentSectionIndex => _currentSectionIndex;

  @override
  int get currentSectionBar => _currentSectionBar;

  @override
  void play() {
    _sub = Metronome().getCurrentBarBeatStream().listen((currentBarBeat) {
      _handleCurrentBarBeatChange(currentBarBeat as int);
    });

    Metronome().start(
      MetronomeSettings(_currentSection.tempo, _currentSection.beatsPerBar,
          _currentSection.clicksPerBeat),
    );
  }

  @override
  void selectNextSection() {
    if (_currentSectionIndex < track.sections.length - 1) {
      _currentSectionIndex++;

      _onSectionChange();
    }
  }

  @override
  void selectPreviousSection() {
    if (_currentSectionIndex > 0) {
      _currentSectionIndex--;

      _onSectionChange();
    }
  }

  @override
  void stop() {
    Metronome().stop();
    _sub.cancel();

    _resetSectionDataToDefaults();
  }

  void _handleCurrentBarBeatChange(int currentBarBeat) {
    if (currentBarBeat == 0) return;

    _changeTempoOnLastBarBeat(currentBarBeat);
    _updateSectionControlData(currentBarBeat);
    _stopIfEndOfSections();
  }

  void _changeTempoOnLastBarBeat(int currentBarBeat) {
    final isNotLastSection = _currentSectionIndex < track.sections.length - 1;
    final isLastSectionBar = _currentSectionBar == _currentSection.barsCount;
    final isLastBarBeat = currentBarBeat == _currentSection.beatsPerBar;

    if (isNotLastSection && isLastSectionBar && isLastBarBeat) {
      final nextSection = track.sections[_currentSectionIndex + 1];
      Metronome().change(
        MetronomeSettings(nextSection.tempo, nextSection.beatsPerBar,
            nextSection.clicksPerBeat),
      );
    }
  }

  void _updateSectionControlData(int currentBarBeat) {
    if (_previousBarBeat > currentBarBeat) {
      _currentSectionBar++;

      if (_currentSectionBar > _currentSection.barsCount) {
        _currentSectionBar = 1;

        _currentSectionIndex++;
      }
    }

    _previousBarBeat = currentBarBeat;
  }

  void _stopIfEndOfSections() {
    if (_currentSectionIndex >= track.sections.length) {
      stop();
    }
  }

  void _onSectionChange() {
    _currentSectionBar = 1;

    final metronomeSettings = MetronomeSettings(_currentSection.tempo,
        _currentSection.beatsPerBar, _currentSection.clicksPerBeat);
    Metronome().change(metronomeSettings);
  }

  void _resetSectionDataToDefaults() {
    _currentSectionIndex = 0;
    _currentSectionBar = 1;
    _previousBarBeat = 1;
  }
}