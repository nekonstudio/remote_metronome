import '../../../metronome/logic/metronome_base.dart';
import '../../models/track.dart';
import 'track_player.dart';

class SimpleTrackPlayer extends TrackPlayer {
  SimpleTrackPlayer(Track track, MetronomeBase metronome) : super(track, metronome) {
    assert(track.isComplex == false);
    print('SimpleTrackPlayer(${track.name})');
  }

  @override
  void play() {
    metronome.start(track.settings);
  }

  @override
  void selectNextSection() {
    // do nothing
  }

  @override
  void selectPreviousSection() {
    // do nothing
  }
}
