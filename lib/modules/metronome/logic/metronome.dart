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
  void onChange(MetronomeSettings settings, {bool immediate = true}) {
    metronomeLib.change(settings.tempo, settings.clicksPerBeat, immediate);
  }

  @override
  void onStop({bool immediate = true}) {
    metronomeLib.stop(immediate: immediate);
  }

  @override
  Stream<dynamic> getCurrentBarBeatStream() {
    return metronomeLib.currentBarBeatStream();
  }
}
