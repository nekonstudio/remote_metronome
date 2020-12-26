import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/track.dart';
import 'metronome/metronome.dart';
import 'metronome/metronome_settings.dart';
import 'metronome/notifier_metronome.dart';

class SetlistPlayer extends ChangeNotifier {
  final NotifierMetronome metronome;

  SetlistPlayer(Reader reader) : metronome = reader(metronomeProvider) {
    print('SetlistPlayer()');
  }

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

      if (_currentSectionBar >= currentSection.barsCount &&
          metronome.currentBarBeat >= currentSection.beatsPerBar) {
        final nextSectionIndex = _currentSectionIndex + 1;
        if (nextSectionIndex < currentTrack.sections.length) {
          final section = currentTrack.sections[nextSectionIndex];
          metronome.change(
            MetronomeSettings(
              section.tempo,
              section.beatsPerBar,
              section.clicksPerBeat,
            ),
          );
        }
      }

      if (_lastBarBeat > metronome.currentBarBeat) {
        _currentSectionBar++;
        print('DAFUQ');

        if (_currentSectionBar > currentSection.barsCount) {
          _currentSectionIndex++;

          if (_currentSectionIndex >= currentTrack.sections.length) {
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
        MetronomeSettings(
          section.tempo,
          section.beatsPerBar,
          section.clicksPerBeat,
        ),
      );
    } else {
      notifyListeners();
    }
  }

  void _onMetronomeChanged() {
    _isPlaying = metronome.isPlaying;
    _handleBarChange();

    notifyListeners();
  }

  void update(List<Track> tracks) {
    _tracks = tracks;
  }

  void play() {
    final settings = currentTrack.isComplex
        ? MetronomeSettings(
            currentSection.tempo,
            currentSection.beatsPerBar,
            currentSection.clicksPerBeat,
          )
        : MetronomeSettings(
            currentTrack.tempo,
            currentTrack.beatsPerBar,
            currentTrack.clicksPerBeat,
          );

    metronome.start(settings);
    metronome.addListener(_onMetronomeChanged);
  }

  void selectNextTrack() {
    if (_currentTrackIndex < _tracks.length - 1) {
      currentTrackIndex++;
    } else {
      currentTrackIndex = 0;
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
    } else {
      currentTrackIndex = _tracks.length - 1;
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

final setlistPlayerProvider =
    ChangeNotifierProvider.autoDispose((ref) => SetlistPlayer(ref.read));
