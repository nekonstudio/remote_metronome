import 'package:flutter/foundation.dart';
import 'package:wakelock/wakelock.dart';

import '../models/metronome_settings.dart';
import 'metronome.dart';

class WakelockMetronome extends Metronome {
  @override
  void onStart(MetronomeSettings settings) {
    startMetronome(settings);

    _toggleScreenWakelock();
  }

  @override
  void onStop() {
    stopMetronome();

    _toggleScreenWakelock();
  }

  @protected
  void startMetronome(MetronomeSettings settings) {
    super.onStart(settings);
  }

  @protected
  void stopMetronome() {
    super.onStop();
  }

  void _toggleScreenWakelock() => Wakelock.toggle(enable: isPlaying);
}
