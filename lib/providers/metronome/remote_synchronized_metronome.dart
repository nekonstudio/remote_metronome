import 'package:metronom/providers/metronome/wakelock_metronome.dart';

import '../remote/remote_synchronization.dart';
import 'metronome.dart';
import 'metronome_settings.dart';

abstract class RemoteSynchronizedMetronome extends WakelockMetronome {
  final RemoteSynchronization synchronization;

  RemoteSynchronizedMetronome(this.synchronization);

  void prepareToRun(MetronomeSettings settings) {
    Metronome.platformChannel.invokeMethod(
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
    Metronome.platformChannel.invokeMethod('syncStart');
  }
}
