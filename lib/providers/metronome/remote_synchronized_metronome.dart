import '../remoteCommand/remote_command.dart';
import '../remote_synchronization.dart';
import 'metronome.dart';

class RemoteSynchronizedMetronome extends Metronome {
  final RemoteSynchronization synchronization;

  RemoteSynchronizedMetronome(this.synchronization);

  @override
  void start(int tempo, int beatsPerBar, int clicksPerBeat,
      {double tempoMultiplier = 1.0}) {
    print('Remote Synchronized Metronome start!');

    synchronization.clientSynchonizedAction(
      RemoteCommand.startMetronome(
        tempo,
        beatsPerBar,
        clicksPerBeat,
        tempoMultiplier,
      ),
      () => super.start(
        tempo,
        beatsPerBar,
        clicksPerBeat,
        tempoMultiplier: tempoMultiplier,
      ),
    );
  }

  @override
  void stop() {
    print('remote stop');

    synchronization.clientSynchonizedAction(
      RemoteCommand.stopMetronome(),
      () => super.stop(),
      instant: true,
    );
  }
}
