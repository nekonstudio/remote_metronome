import '../../../metronome/logic/metronome.dart';
import '../../../metronome/logic/wakelock_metronome.dart';
import '../../../metronome/models/metronome_settings.dart';
import '../remote_synchronization.dart';

abstract class RemoteSynchronizedMetronome extends WakelockMetronome {
  static const commandExecutionDuration = Duration(milliseconds: 500);

  final RemoteSynchronization synchronization;

  RemoteSynchronizedMetronome(this.synchronization);

  void prepareSynchronizedStart(MetronomeSettings settings) {
    Metronome.platformChannel.invokeMethod(
      'prepareSynchronizedStart',
      {
        'tempo': settings.tempo,
        'beatsPerBar': settings.beatsPerBar,
        'clicksPerBeat': settings.clicksPerBeat,
      },
    );
  }

  void runSynchronizedStart() {
    Metronome.platformChannel.invokeMethod('synchronizedStart');
  }
}
