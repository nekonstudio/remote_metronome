import '../../../metronome/logic/metronome_base.dart';
import '../../models/track.dart';
import 'track_player.dart';

class NoTrackPlayer extends TrackPlayer {
  NoTrackPlayer(Track track, MetronomeBase metronome) : super(track, metronome) {
    print('NoTrackPlayer');
  }

  @override
  void play() {
    // Do nothing
  }

  @override
  void selectNextSection() {
    // Do nothing
  }

  @override
  void selectPreviousSection() {
    // Do nothing
  }
}
