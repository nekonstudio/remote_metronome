import 'package:metronom/models/section.dart';
import 'package:metronom/models/track.dart';

abstract class SetlistPlayerInterface {
  void play();
  void selectNextTrack();
  void selectPreviousTrack();
  void selectTrack(int index);
  void selectNextSection();
  void selectPreviousSection();
  void stop();
  void update();

  bool get isPlaying;

  int get currentTrackIndex;
  int get currentSectionIndex;
  int get currentSectionBar;

  Track get currentTrack;
  Section get currentSection;

  set onTrackChanged(void Function(int trackIndex) callback);
}
