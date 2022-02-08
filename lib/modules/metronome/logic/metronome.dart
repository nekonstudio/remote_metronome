import 'dart:async';

import 'package:flutter/material.dart';
import 'package:metronom/native_android_metronome_bridge.dart';

import '../models/metronome_settings.dart';
import 'metronome_base.dart';

class Metronome extends MetronomeBase {
  @protected
  static final metronomeLib = NativeAndroidMetronomeBridge();

  @override
  void onStart(MetronomeSettings settings) {
    metronomeLib.start(
        settings.tempo, settings.clicksPerBeat, settings.beatsPerBar);
  }

  @override
  void onChange(MetronomeSettings settings) {
    metronomeLib.change(settings.tempo, settings.clicksPerBeat);
  }

  @override
  void onStop() {
    metronomeLib.stop();
  }

  @override
  Stream<dynamic> getCurrentBarBeatStream() {
    return metronomeLib.currentBarBeatStream();
  }
}
