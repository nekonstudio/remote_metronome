import 'package:metronom/modules/metronome/models/metronome_settings.dart';

abstract class MetronomeInterface {
  void start(MetronomeSettings settings);
  void change(MetronomeSettings newSettings);
  void stop();

  bool get isPlaying;
  int get currentBarBeat;
}
