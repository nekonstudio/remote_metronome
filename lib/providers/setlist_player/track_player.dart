import '../../models/track.dart';
import '../metronome/metronome_base.dart';
import 'complex_track_player.dart';
import 'no_track_player.dart';
import 'simple_track_player.dart';

abstract class TrackPlayer {
  final Track track;
  final MetronomeBase metronome;

  TrackPlayer(this.track, this.metronome);

  factory TrackPlayer.createPlayerForTrack(Track track, MetronomeBase metronome) {
    if (track == null) return NoTrackPlayer(track, metronome);

    return track.isComplex
        ? ComplexTrackPlayer(track, metronome)
        : SimpleTrackPlayer(track, metronome);
  }

  bool get isPlaying => metronome.isPlaying;
  int get currentSectionIndex => null;
  int get currentSectionBar => null;

  void play();
  void selectNextSection();
  void selectPreviousSection();

  void stop() {
    metronome.stop();
  }
}
