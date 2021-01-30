import 'package:metronom/providers/metronome/metronome_interface.dart';

import '../remote/remote_command.dart';
import '../remote/remote_synchronization.dart';
import 'metronome.dart';
import 'metronome_settings.dart';

class RemoteSynchronizedMetronome implements MetronomeInterface {
  final RemoteSynchronization synchronization;
  final Metronome metronome;

  RemoteSynchronizedMetronome(this.synchronization, this.metronome);

  @override
  void start(MetronomeSettings settings) {
    print('Remote Synchronized Metronome start!');

    synchronization.hostStartMetronome(metronome, settings);

    // synchronization.clientSynchonizedAction(
    //   RemoteCommand.startMetronome(settings),
    //   () => metronome.start(settings),
    // );
  }

  @override
  void stop() {
    print('remote stop');

    synchronization.clientSynchonizedAction(
      RemoteCommand.stopMetronome(),
      () => metronome.stop(),
      instant: true,
    );
  }

  @override
  void change(MetronomeSettings newSettings) {
    // do nothing on remote metronome change
  }

  @override
  int get currentBarBeat => metronome.currentBarBeat;

  @override
  bool get isPlaying => metronome.isPlaying;

  @override
  void syncStart() {
    // TODO: implement syncStart
  }

  @override
  void syncStartPrepare(MetronomeSettings settings) {
    // TODO: implement syncStartPrepare
  }
}
