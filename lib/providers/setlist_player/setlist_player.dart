import 'package:metronom/models/track.dart';
import 'package:metronom/providers/setlist_player/track_player.dart';

import '../../models/setlist.dart';

class SetlistPlayer {
  final Setlist setlist;

  TrackPlayer _trackPlayer;
  int _currentTrackIndex;
  void Function(int) _onTrackChanged;

  SetlistPlayer(this.setlist) {
    _currentTrackIndex = 0;

    _trackPlayer = TrackPlayer.createPlayerForTrack(_currentTrack);
  }

  set onTrackChanged(void Function(int) callback) => _onTrackChanged = callback;

  int get currentTrackIndex => _currentTrackIndex;
  int get currentSectionIndex => _trackPlayer.currentSectionIndex;
  int get currentSectionBar => _trackPlayer.currentSectionBar;

  Track get _currentTrack => setlist.tracks[_currentTrackIndex];

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
    if (index != _currentTrackIndex)
      _handleTrackChange(() => _currentTrackIndex = index);
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

  void _handleTrackChange(Function trackChangeFunction) {
    if (isPlaying) {
      stop();
    }

    trackChangeFunction();
    _onTrackChanged?.call(_currentTrackIndex);

    _trackPlayer = TrackPlayer.createPlayerForTrack(_currentTrack);
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
