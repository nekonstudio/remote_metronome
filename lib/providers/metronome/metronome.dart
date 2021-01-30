import 'dart:async';

import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

import 'metronome_base.dart';
import 'metronome_settings.dart';

class Metronome extends MetronomeBase {
  static Metronome _instance;

  factory Metronome() {
    if (_instance == null) {
      _instance = Metronome._();
    }
    return _instance;
  }

  Metronome._() {
    // platformLatencyStream.listen(_setPlatformLatency);
  }

  static const _metronomePlatformChannel = const MethodChannel('com.example.metronom/metronom');

  final Stream<dynamic> currentBarBeatStream =
      const EventChannel('com.example.metronom/barBeatChannel').receiveBroadcastStream();

  // final Stream<dynamic> platformLatencyStream =
  //     const EventChannel('com.example.metronom/platformLatencyChannel').receiveBroadcastStream();

  // int _platformLatency = 0;
  // DateTime _platformExecutionTimestamp;

  @override
  void onStart(MetronomeSettings settings) {
    // _platformExecutionTimestamp = DateTime.now();

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

  @override
  void onSyncStartPrepare(MetronomeSettings settings) {
    // TODO: implement onSyncStartPrepare
    _metronomePlatformChannel.invokeMethod('syncStartPrepare', {
      'tempo': settings.tempo,
      'beatsPerBar': settings.beatsPerBar,
      'clicksPerBeat': settings.clicksPerBeat,
      'tempoMultiplier': 1.0 // TODO: remove from platform implementation
    });
  }

  @override
  void onSyncStart() {
    // TODO: implement onSyncStart
    _metronomePlatformChannel.invokeMethod('syncStart');
  }

  void _invokePlatformMethod(String methodName, [Map<String, dynamic> parameters]) {
    _metronomePlatformChannel.invokeMethod(methodName, parameters);
  }

  void _toggleScreenWakelock() => Wakelock.toggle(enable: isPlaying);

  // void _setPlatformLatency(dynamic value) {
  //   // print(value);
  //   _platformLatency = DateTime.fromMillisecondsSinceEpoch(value)
  //       .difference(_platformExecutionTimestamp)
  //       .inMilliseconds;

  //   print('platformLatency: $_platformLatency ms');
  // }
}
