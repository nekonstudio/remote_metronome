import 'package:flutter/cupertino.dart';

import '../models/track.dart';
import 'metronome.dart';

class SetlistPlayer extends ChangeNotifier {
  final Metronome metronome;

  SetlistPlayer(this.metronome) {}

  List<Track> _tracks;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  int _currentTrackIndex = 0;
  int get currentTrackIndex => _currentTrackIndex;
  Track get currentTrack =>
      _tracks != null ? _tracks[_currentTrackIndex] : null;

  set currentTrackIndex(int index) {
    if (_currentTrackIndex != index) {
      _currentTrackIndex = index;
      _currentSectionIndex = SectionIndexDefaultValue;
      _currentSectionBar = SectionBarDefaultValue;
      _lastBarBeat = 0;

      metronome.stop();
      _onTrackChangedCallback?.call();

      notifyListeners();
    }
  }

  static const SectionIndexDefaultValue = 0;
  int _currentSectionIndex = SectionIndexDefaultValue;
  int get currentSectionIndex => _currentSectionIndex;
  Section get currentSection => currentTrack.sections[_currentSectionIndex];

  static const SectionBarDefaultValue = 1;
  int _currentSectionBar = SectionBarDefaultValue;
  int get currentSectionBar => _currentSectionBar;

  Function _onTrackChangedCallback;
  set onTrackChangedCallback(Function callback) =>
      _onTrackChangedCallback = callback;

  int _lastBarBeat = 0;
  void _handleBarChange() {
    if (currentTrack.isComplex && _isPlaying) {
      print(
          'lastBarBeat: $_lastBarBeat, currentBarBeat: ${metronome.currentBarBeat}');
      if (_lastBarBeat > metronome.currentBarBeat) {
        _currentSectionBar++;
        print('DAFUQ');
        if (_currentSectionBar > currentSection.barsCount) {
          _currentSectionIndex++;

          if (_currentSectionIndex < currentTrack.sections.length) {
            final section = currentSection;
            metronome.change(
              tempo: section.tempo,
              beatsPerBar: section.beatsPerBar,
              clicksPerBeat: section.clicksPerBeat,
            );
          } else {
            selectNextTrack();
            _currentSectionIndex = SectionIndexDefaultValue;
          }

          _currentSectionBar = SectionBarDefaultValue;
        }
      }

      print('_handleBarChange: $_currentSectionBar');

      _lastBarBeat = metronome.currentBarBeat;
    }
  }

  void _applyNewSection() {
    _currentSectionBar = SectionBarDefaultValue;

    if (_isPlaying) {
      final section = currentSection;
      metronome.change(
        tempo: section.tempo,
        beatsPerBar: section.beatsPerBar,
        clicksPerBeat: section.clicksPerBeat,
      );
    } else {
      notifyListeners();
    }
  }

  void _onMetronomeChanged() {
    _isPlaying = metronome.isPlaying;
    _handleBarChange();
  }

  void update(List<Track> tracks) {
    _tracks = tracks;
  }

  void play() {
    if (currentTrack.isComplex) {
      final section = currentSection;
      metronome.start(
          section.tempo, section.beatsPerBar, section.clicksPerBeat);
    } else {
      metronome.startTrack(currentTrack);
    }

    metronome.addListener(_onMetronomeChanged);
  }

  void selectNextTrack() {
    if (_currentTrackIndex < _tracks.length - 1) {
      currentTrackIndex++;
    }
  }

  void selectNextSection() {
    if (currentTrack.isComplex &&
        _currentSectionIndex < currentTrack.sections.length - 1) {
      _currentSectionIndex++;

      _applyNewSection();
    }
  }

  void selectPreviousSection() {
    if (_currentSectionIndex > 0) {
      _currentSectionIndex--;

      _applyNewSection();
    }
  }

  void selectPreviousTrack() {
    if (_currentTrackIndex > 0) {
      currentTrackIndex--;
    }
  }

  void stop() {
    if (currentTrack.isComplex) {
      _currentSectionIndex = SectionIndexDefaultValue;
      _currentSectionBar = SectionBarDefaultValue;
      _lastBarBeat = 0;

      print('STOP: $_currentSectionBar');
      print('is playing? $_isPlaying');
    }

    metronome.stop();
    metronome.removeListener(_onMetronomeChanged);
  }
}
