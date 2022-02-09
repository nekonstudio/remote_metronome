import 'package:metronom/modules/metronome/models/metronome_settings.dart';

abstract class MetronomeInterface {
  void start(MetronomeSettings settings);
  void change(MetronomeSettings newSettings, {bool immediate = true});
  void stop({bool immediate = true});

  bool get isPlaying;
  int? get currentBarBeat;
}
