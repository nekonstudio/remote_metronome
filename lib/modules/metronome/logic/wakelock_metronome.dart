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
  void onStop({bool immediate = true}) {
    stopMetronome(immediate: immediate);

    _toggleScreenWakelock();
  }

  @protected
  void startMetronome(MetronomeSettings settings) {
    super.onStart(settings);
  }

  @protected
  void stopMetronome({bool immediate = true}) {
    super.onStop(immediate: immediate);
  }

  void _toggleScreenWakelock() => Wakelock.toggle(enable: isPlaying);
}
