abstract class SetlistPlayerInterace {
  void play();
  void selectNextTrack();
  void selectPreviousTrack();
  void selectNextSection();
  void selectPreviousSection();
  void stop();

  bool get isPlaying;
}
