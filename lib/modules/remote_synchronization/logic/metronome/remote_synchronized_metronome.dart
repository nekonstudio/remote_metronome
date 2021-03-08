import '../../../metronome/logic/metronome.dart';
import '../../../metronome/logic/wakelock_metronome.dart';
import '../../../metronome/models/metronome_settings.dart';
import '../remote_synchronization.dart';

abstract class RemoteSynchronizedMetronome extends WakelockMetronome {
  final RemoteSynchronization synchronization;

  RemoteSynchronizedMetronome(this.synchronization);

  void prepareToRun(MetronomeSettings settings) {
    Metronome.platformChannel.invokeMethod(
      'prepareSynchronizedStart',
      {
        'tempo': settings.tempo,
        'beatsPerBar': settings.beatsPerBar,
        'clicksPerBeat': settings.clicksPerBeat,
      },
    );
  }

  void run() {
    Metronome.platformChannel.invokeMethod('synchronizedStart');
  }
}
