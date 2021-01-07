import 'package:flutter/foundation.dart';
import 'package:metronom/models/setlist.dart';
import 'package:metronom/providers/metronome/metronome.dart';
import 'package:metronom/providers/setlist_player/setlist_player.dart';

class NotifierSetlistPlayer extends SetlistPlayer with ChangeNotifier {
  bool _previousIsPlayingValue;
  int _previousCurrentTrackIndexValue;
  int _previousCurrentSectionIndexValue;
  int _previousCurrentSectionBarValue;

  NotifierSetlistPlayer(Setlist setlist) : super(setlist) {
    _previousIsPlayingValue = isPlaying;
    _previousCurrentTrackIndexValue = currentTrackIndex;
    _previousCurrentSectionIndexValue = currentSectionIndex;
    _previousCurrentSectionBarValue = currentSectionBar;

    Metronome().getCurrentBarBeatStream().listen(
          (_) => _onCurrentBarBeatChanged(),
        );
  }

  @override
  void play() {
    super.play();

    if (isPlaying != _previousIsPlayingValue) {
      _previousIsPlayingValue = isPlaying;

      notifyListeners();
    }
  }

  @override
  void selectNextTrack() {
    super.selectNextTrack();

    if (currentTrackIndex != _previousCurrentTrackIndexValue) {
      _previousCurrentTrackIndexValue = currentTrackIndex;

      notifyListeners();
    }
  }

  @override
  void selectPreviousTrack() {
    super.selectPreviousTrack();

    if (currentTrackIndex != _previousCurrentTrackIndexValue) {
      _previousCurrentTrackIndexValue = currentTrackIndex;

      notifyListeners();
    }
  }

  @override
  void selectTrack(int index) {
    super.selectTrack(index);

    if (currentTrackIndex != _previousCurrentTrackIndexValue) {
      _previousCurrentTrackIndexValue = currentTrackIndex;

      notifyListeners();
    }
  }

  @override
  void selectNextSection() {
    super.selectNextSection();

    if (_previousCurrentSectionIndexValue != currentSectionIndex) {
      _previousCurrentSectionIndexValue = currentSectionIndex;

      notifyListeners();
    }
  }

  @override
  void selectPreviousSection() {
    super.selectPreviousSection();

    if (_previousCurrentSectionIndexValue != currentSectionIndex) {
      _previousCurrentSectionIndexValue = currentSectionIndex;

      notifyListeners();
    }
  }

  @override
  void stop() {
    super.stop();

    if (isPlaying != _previousIsPlayingValue) {
      _previousIsPlayingValue = isPlaying;

      notifyListeners();
    }
  }

  void _onCurrentBarBeatChanged() {
    // HACK!
    // This is delayed a little bit to ensure that values have changed
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
}
