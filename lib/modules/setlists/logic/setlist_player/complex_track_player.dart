import 'dart:async';

import '../../../metronome/logic/metronome_base.dart';
import '../../models/section.dart';
import '../../models/track.dart';
import 'track_player.dart';

class ComplexTrackPlayer extends TrackPlayer {
  ComplexTrackPlayer(Track track, MetronomeBase metronome) : super(track, metronome) {
    assert(track.isComplex == true);

    print('ComplexTrackPlayer(${track.name})');
  }

  int _currentSectionIndex = 0;
  int _currentSectionBar = 1;
  int _currentClickPerBeat = 1;
  int _previousBarBeat = 1;
  StreamSubscription<dynamic> _sub;

  @override
  void copy(TrackPlayer other) {
    final complexTrackPlayer = other as ComplexTrackPlayer;
    _currentSectionIndex = complexTrackPlayer.currentSectionIndex;
    _currentSectionBar = complexTrackPlayer.currentSectionBar;
    _previousBarBeat = complexTrackPlayer._previousBarBeat;

    if (isPlaying) {
      _sub = metronome.getCurrentBarBeatStream().listen((currentBarBeat) {
        _handleCurrentBarBeatChange(currentBarBeat as int);
      });
    }
  }

  Section get _currentSection => track.sections[_currentSectionIndex];

  @override
  int get currentSectionIndex => _currentSectionIndex;

  @override
  int get currentSectionBar => _currentSectionBar;

  @override
  void play() {
    _sub = metronome.getCurrentBarBeatStream().listen((currentBarBeat) {
      _handleCurrentBarBeatChange(currentBarBeat as int);
    });

    metronome.start(_currentSection.settings);
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
    metronome.stop();
    _sub?.cancel();

    _resetSectionDataToDefaults();
  }

  void _handleCurrentBarBeatChange(int currentBarBeat) {
    if (currentBarBeat == 0) return;

    _changeToNextSectionOnLastBarBeat(currentBarBeat);
    _updateSectionControlData(currentBarBeat);
    _stopIfEndOfSections();
  }

  void _changeToNextSectionOnLastBarBeat(int currentBarBeat) {
    final isNotLastSection = _currentSectionIndex < track.sections.length - 1;
    final isLastSectionBar = _currentSectionBar == _currentSection.barsCount;
    final isLastBarBeat = currentBarBeat == _currentSection.settings.beatsPerBar;

    final sectionClicksPerBeat = _currentSection.settings.clicksPerBeat;
    final isPenultimateClickPerBeat =
        sectionClicksPerBeat == 1 || _currentClickPerBeat == sectionClicksPerBeat;

    if (isNotLastSection && isLastSectionBar && isLastBarBeat && isPenultimateClickPerBeat) {
      final nextSection = track.sections[_currentSectionIndex + 1];
      metronome.change(nextSection.settings);
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

    if (_currentSectionIndex < track.sections.length) {
      _currentClickPerBeat++;
      if (_currentClickPerBeat > _currentSection.settings.clicksPerBeat) {
        _currentClickPerBeat = 1;
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

    metronome.change(_currentSection.settings);
  }

  void _resetSectionDataToDefaults() {
    _currentSectionIndex = 0;
    _currentSectionBar = 1;
    _previousBarBeat = 1;
    _currentClickPerBeat = 1;
  }
}
