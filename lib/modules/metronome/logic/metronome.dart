import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/metronome_settings.dart';
import 'metronome_base.dart';

class Metronome extends MetronomeBase {
  @protected
  static const platformChannel = const MethodChannel('com.example.metronom/metronom');

  static Stream<dynamic> currentBarBeatStream =
      const EventChannel('com.example.metronom/barBeatChannel').receiveBroadcastStream();

  @override
  void onStart(MetronomeSettings settings) {
    invokePlatformMethod(
      'start',
      {
        'tempo': settings.tempo,
        'beatsPerBar': settings.beatsPerBar,
        'clicksPerBeat': settings.clicksPerBeat,
      },
    );
  }

  @override
  void onChange(MetronomeSettings settings) {
    invokePlatformMethod(
      'change',
      {
        'tempo': settings.tempo,
        'beatsPerBar': settings.beatsPerBar,
        'clicksPerBeat': settings.clicksPerBeat,
      },
    );
  }

  @override
  void onStop() {
    invokePlatformMethod('stop');
  }

  @override
  Stream<dynamic> getCurrentBarBeatStream() {
    return currentBarBeatStream;
  }

  @protected
  void invokePlatformMethod(String methodName, [Map<String, dynamic> parameters]) {
    platformChannel.invokeMethod(methodName, parameters);
  }
}
