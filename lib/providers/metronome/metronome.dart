import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

import 'metronome_base.dart';
import 'metronome_settings.dart';

class Metronome extends MetronomeBase {
  @protected
  static const platformChannel = const MethodChannel('com.example.metronom/metronom');

  static Stream<dynamic> currentBarBeatStream =
      const EventChannel('com.example.metronom/barBeatChannel').receiveBroadcastStream();

  @override
  void onStart(MetronomeSettings settings) {
    _invokePlatformMethod(
      'start',
      {
        'tempo': settings.tempo,
        'beatsPerBar': settings.beatsPerBar,
        'clicksPerBeat': settings.clicksPerBeat,
        'tempoMultiplier': 1.0 // TODO: remove from platform implementation
      },
    );

    _toggleScreenWakelock();
  }

  @override
  void onChange(MetronomeSettings settings) {
    _invokePlatformMethod(
      'smoothChange',
      {
        'tempo': settings.tempo,
        'beatsPerBar': settings.beatsPerBar,
        'clicksPerBeat': settings.clicksPerBeat,
        'tempoMultiplier': 1.0 // TODO: remove from platform implementation
      },
    );
  }

  @override
  void onStop() {
    _invokePlatformMethod('stop');

    _toggleScreenWakelock();
  }

  @override
  Stream<dynamic> getCurrentBarBeatStream() {
    return currentBarBeatStream;
  }

  void _invokePlatformMethod(String methodName, [Map<String, dynamic> parameters]) {
    platformChannel.invokeMethod(methodName, parameters);
  }

  void _toggleScreenWakelock() => Wakelock.toggle(enable: isPlaying);
}
