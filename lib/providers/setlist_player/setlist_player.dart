import 'package:flutter/material.dart';

import '../../models/section.dart';
import '../../models/setlist.dart';
import '../../models/track.dart';
import '../metronome/metronome_base.dart';
import 'setlist_player_interface.dart';
import 'track_player.dart';

class SetlistPlayer implements SetlistPlayerInterface {
  final Setlist setlist;
  final MetronomeBase metronome;

  TrackPlayer _trackPlayer;
  int _currentTrackIndex;
  void Function(int) _onTrackChanged;

  SetlistPlayer(this.setlist, this.metronome) {
    if (setlist.hasTracks) {
      _currentTrackIndex = 0;
    }

    createTrackPlayer(currentTrack);
  }

  void copy(SetlistPlayer other) {
    // order of execution matters
    _currentTrackIndex = other.currentTrackIndex;
    metronome.copy(other.metronome);
    createTrackPlayer(currentTrack);
    _trackPlayer.copy(other._trackPlayer);
  }

  void createTrackPlayer(Track track) {
    _trackPlayer = TrackPlayer.createPlayerForTrack(track, metronome);
  }

  set onTrackChanged(void Function(int) callback) => _onTrackChanged = callback;

  int get currentTrackIndex => _currentTrackIndex;
  int get currentSectionIndex => _trackPlayer.currentSectionIndex;
  int get currentSectionBar => _trackPlayer.currentSectionBar;

  Track get currentTrack => setlist.tracksCount > 0 ? setlist.tracks[_currentTrackIndex] : null;
  Section get currentSection => currentTrack?.sections?.elementAt(currentSectionIndex);

  bool get isPlaying => _trackPlayer.isPlaying;

  void play() {
    _trackPlayer.play();
  }

  void selectNextTrack() {
    _handleTrackChange(_setNextTrackIndex);
  }

  void selectPreviousTrack() {
    _handleTrackChange(_setPreviousTrackIndex);
  }

  void selectTrack(int index) {
    if (index != _currentTrackIndex) {
      if (index >= 0) {
        _handleTrackChange(() => _currentTrackIndex = index);
      }
    }
  }

  void selectNextSection() {
    _trackPlayer.selectNextSection();
  }

  void selectPreviousSection() {
    _trackPlayer.selectPreviousSection();
  }

  void stop() {
    _trackPlayer.stop();
  }

  void update() {
    if (setlist.hasTracks) {
      _currentTrackIndex = 0;
    }

    createTrackPlayer(currentTrack);
  }

  void _handleTrackChange(Function trackChangeFunction) {
    if (isPlaying) {
      stop();
    }

    trackChangeFunction();
    _onTrackChanged?.call(_currentTrackIndex);

    // _trackPlayer = TrackPlayer.createPlayerForTrack(currentTrack);
    createTrackPlayer(currentTrack);
  }

  void _setNextTrackIndex() {
    if (_currentTrackIndex < setlist.tracks.length - 1) {
      _currentTrackIndex++;
    } else {
      _currentTrackIndex = 0;
    }
  }

  void _setPreviousTrackIndex() {
    if (_currentTrackIndex > 0) {
      _currentTrackIndex--;
    } else {
      _currentTrackIndex = setlist.tracks.length - 1;
    }
  }
}
