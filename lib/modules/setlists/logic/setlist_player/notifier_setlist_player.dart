import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/section.dart';
import '../../models/track.dart';
import 'setlist_player.dart';
import 'setlist_player_interface.dart';

class NotifierSetlistPlayer with ChangeNotifier implements SetlistPlayerInterface {
  final SetlistPlayer impl;

  bool _previousIsPlayingValue;
  int _previousCurrentTrackIndexValue;
  int _previousCurrentSectionIndexValue;

  StreamSubscription<dynamic> _currentBarBeatSubscription;

  NotifierSetlistPlayer(this.impl) {
    _previousIsPlayingValue = impl.isPlaying;
    _previousCurrentTrackIndexValue = impl.currentTrackIndex;
    _previousCurrentSectionIndexValue = impl.currentSectionIndex;

    _currentBarBeatSubscription =
        impl.metronome.getCurrentBarBeatStream().listen((_) => _onCurrentBarBeatChanged());
  }

  @override
  void dispose() {
    _currentBarBeatSubscription.cancel();
    super.dispose();
  }

  @override
  Track get currentTrack => impl.currentTrack;

  @override
  int get currentTrackIndex => impl.currentTrackIndex;

  @override
  Section get currentSection => impl.currentSection;

  @override
  int get currentSectionBar => impl.currentSectionBar;

  @override
  int get currentSectionIndex => impl.currentSectionIndex;

  @override
  void play() {
    impl.play();

    if (isPlaying != _previousIsPlayingValue) {
      _previousIsPlayingValue = isPlaying;

      notifyListeners();
    }
  }

  @override
  void selectNextTrack() {
    impl.selectNextTrack();

    if (currentTrackIndex != _previousCurrentTrackIndexValue) {
      _previousCurrentTrackIndexValue = currentTrackIndex;

      notifyListeners();
    }
  }

  @override
  void selectPreviousTrack() {
    impl.selectPreviousTrack();

    if (currentTrackIndex != _previousCurrentTrackIndexValue) {
      _previousCurrentTrackIndexValue = currentTrackIndex;

      notifyListeners();
    }
  }

  @override
  void selectTrack(int index) {
    impl.selectTrack(index);

    if (currentTrackIndex != _previousCurrentTrackIndexValue) {
      _previousCurrentTrackIndexValue = currentTrackIndex;

      notifyListeners();
    }
  }

  @override
  void selectNextSection() {
    impl.selectNextSection();

    if (_previousCurrentSectionIndexValue != currentSectionIndex) {
      _previousCurrentSectionIndexValue = currentSectionIndex;

      notifyListeners();
    }
  }

  @override
  void selectPreviousSection() {
    impl.selectPreviousSection();

    if (_previousCurrentSectionIndexValue != currentSectionIndex) {
      _previousCurrentSectionIndexValue = currentSectionIndex;

      notifyListeners();
    }
  }

  @override
  void stop() {
    impl.stop();

    if (isPlaying != _previousIsPlayingValue) {
      _previousIsPlayingValue = isPlaying;

      notifyListeners();
    }
  }

  @override
  bool get isPlaying => impl.isPlaying;

  void _onCurrentBarBeatChanged() => notifyListeners();

  @override
  set onTrackChanged(void Function(int trackIndex) callback) => impl.onTrackChanged = callback;

  @override
  void update() {
    impl.update();

    notifyListeners();
  }
}
