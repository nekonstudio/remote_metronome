import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metronom/native_android_metronome_bridge.dart';

import '../models/metronome_settings.dart';
import 'metronome_base.dart';

class Metronome extends MetronomeBase {
  static final _metronomeLib = NativeAndroidMetronomeBridge();

  @protected
  static const platformChannel =
      const MethodChannel('com.example.metronom/metronom');

  static Stream<dynamic> currentBarBeatStream =
      const EventChannel('com.example.metronom/barBeatChannel')
          .receiveBroadcastStream();

  @override
  void onStart(MetronomeSettings settings) {
    _metronomeLib.start(
        settings.tempo, settings.clicksPerBeat, settings.beatsPerBar);
  }

  @override
  void onChange(MetronomeSettings settings) {
    _metronomeLib.change(settings.tempo, settings.clicksPerBeat);
  }

  @override
  void onStop() {
    _metronomeLib.stop();
  }

  @override
  Stream<dynamic> getCurrentBarBeatStream() {
    return _metronomeLib.currentBarBeatStream();
  }

  @protected
  void invokePlatformMethod(String methodName,
      [Map<String, dynamic>? parameters]) {
    platformChannel.invokeMethod(methodName, parameters);
  }
}
