import 'dart:async';

import 'package:flutter/services.dart';

import 'metronome.dart';
import 'metronome_settings.dart';

class MetronomeImpl extends Metronome {
  static const _metronomePlatformChannel =
      const MethodChannel('com.example.metronom/metronom');

  final Stream<dynamic> currentBarBeatStream =
      const EventChannel('com.example.metronom/barBeatChannel')
          .receiveBroadcastStream();

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
  }

  void _invokePlatformMethod(String methodName,
      [Map<String, dynamic> parameters]) {
    _metronomePlatformChannel.invokeMethod(methodName, parameters);
  }

  @override
  Stream<dynamic> getCurrentBarBeatStream() {
    return currentBarBeatStream;
  }
}
