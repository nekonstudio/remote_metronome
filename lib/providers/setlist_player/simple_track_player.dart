import 'package:metronom/models/track.dart';
import 'package:metronom/providers/metronome/metronome.dart';
import 'package:metronom/providers/metronome/metronome_settings.dart';
import 'package:metronom/providers/setlist_player/track_player.dart';

class SimpleTrackPlayer extends TrackPlayer {
  SimpleTrackPlayer(Track track) : super(track) {
    assert(track.isComplex == false);
    print('SimpleTrackPlayer(${track.name})');
  }

  @override
  void play() {
    Metronome().start(track.settings);
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
