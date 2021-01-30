import 'metronome_settings.dart';

abstract class MetronomeInterface {
  void start(MetronomeSettings settings);
  void change(MetronomeSettings newSettings);
  void stop();

  void syncStartPrepare(MetronomeSettings settings);
  void syncStart();

  bool get isPlaying;
  int get currentBarBeat;
}
