import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:metronom/models/section.dart';
import 'package:metronom/models/setlist.dart';
import 'package:metronom/models/track.dart';
import 'package:metronom/providers/metronome/metronome.dart';
import 'package:metronom/providers/setlist_player/setlist_player.dart';
import 'package:metronom/providers/setlist_player/setlist_player_interface.dart';

class NotifierSetlistPlayer with ChangeNotifier implements SetlistPlayerInterface {
  final SetlistPlayer impl;

  bool _previousIsPlayingValue;
  int _previousCurrentTrackIndexValue;
  int _previousCurrentSectionIndexValue;
  int _previousCurrentSectionBarValue;
  StreamSubscription<dynamic> _subscription;

  NotifierSetlistPlayer(this.impl) {
    _previousIsPlayingValue = impl.isPlaying;
    _previousCurrentTrackIndexValue = impl.currentTrackIndex;
    _previousCurrentSectionIndexValue = impl.currentSectionIndex;
    _previousCurrentSectionBarValue = impl.currentSectionBar;

    _subscription = impl.metronome.getCurrentBarBeatStream().listen(
          (_) => _onCurrentBarBeatChanged(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
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

  void _onCurrentBarBeatChanged() {
    // HACK!
    // This is delayed a little bit to ensure that values have changed
    // notifyListeners();
    Future.delayed(Duration(milliseconds: 10), () {
      if (_previousCurrentSectionIndexValue != currentSectionIndex) {
        _previousCurrentSectionIndexValue = currentSectionIndex;

        notifyListeners();
      }

      if (_previousCurrentSectionBarValue != currentSectionBar) {
        _previousCurrentSectionBarValue = currentSectionBar;

        notifyListeners();
      }
    });
  }

  @override
  set onTrackChanged(void Function(int trackIndex) callback) => impl.onTrackChanged = callback;
}
