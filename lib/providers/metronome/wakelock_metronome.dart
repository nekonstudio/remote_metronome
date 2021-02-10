import 'package:flutter/cupertino.dart';
import 'package:metronom/providers/metronome/metronome.dart';
import 'package:wakelock/wakelock.dart';

import 'metronome_settings.dart';

class WakelockMetronome extends Metronome {
  @override
  void onStart(MetronomeSettings settings) {
    startImplementation(settings);

    _toggleScreenWakelock();
  }

  @override
  void onStop() {
    stopImplementation();

    _toggleScreenWakelock();
  }

  @protected
  void startImplementation(MetronomeSettings settings) {
    super.onStart(settings);
  }

  @protected
  void stopImplementation() {
    super.onStop();
  }

  void _toggleScreenWakelock() => Wakelock.toggle(enable: isPlaying);
}
