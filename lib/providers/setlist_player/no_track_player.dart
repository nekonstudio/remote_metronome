import 'package:metronom/models/track.dart';
import 'package:metronom/providers/setlist_player/track_player.dart';

class NoTrackPlayer extends TrackPlayer {
  NoTrackPlayer(Track track) : super(track);

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
