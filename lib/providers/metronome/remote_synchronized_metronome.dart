import 'package:flutter/services.dart';

import '../remote/remote_synchronization.dart';
import 'metronome.dart';
import 'metronome_base.dart';
import 'metronome_settings.dart';

abstract class RemoteSynchronizedMetronome extends MetronomeBase {
  final RemoteSynchronization synchronization;

  RemoteSynchronizedMetronome(this.synchronization);

  static const _metronomePlatformChannel = const MethodChannel('com.example.metronom/metronom');

  @override
  void onChange(MetronomeSettings newSettings) {
    // do nothing on remote metronome change
  }

  @override
  void onStop() {
    Metronome().onStop();
  }

  @override
  Stream getCurrentBarBeatStream() => Metronome().currentBarBeatStream;

  void prepareToRun(MetronomeSettings settings) {
    _metronomePlatformChannel.invokeMethod(
      'syncStartPrepare',
      {
        'tempo': settings.tempo,
        'beatsPerBar': settings.beatsPerBar,
        'clicksPerBeat': settings.clicksPerBeat,
        'tempoMultiplier': 1.0 // TODO: remove from platform implementation
      },
    );
  }

  void run() {
    _metronomePlatformChannel.invokeMethod('syncStart');
  }
}
