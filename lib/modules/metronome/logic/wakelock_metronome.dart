import 'package:flutter/foundation.dart';
import 'package:wakelock/wakelock.dart';

import '../models/metronome_settings.dart';
import 'metronome.dart';

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
