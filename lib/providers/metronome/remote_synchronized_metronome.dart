import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../nearby/nearby_devices.dart';
import '../remoteCommand/remote_command.dart';
import 'metronome.dart';

class RemoteSynchronizedMetronome extends Metronome {
  final Reader providerReader;

  RemoteSynchronizedMetronome(this.providerReader);

  @override
  void start(int tempo, int beatsPerBar, int clicksPerBeat,
      {double tempoMultiplier = 1.0}) {
    print('Remote Synchronized Metronome start!');

    print('hostStartTime: ${DateTime.now()}');
    providerReader(nearbyDevicesProvider).broadcastCommand(
        RemoteCommand.startMetronome(
            tempo, beatsPerBar, clicksPerBeat, tempoMultiplier));

    Future.delayed(Duration(milliseconds: 500), () {
      print('HOST START! time:\t' + DateTime.now().toString());

      super.start(tempo, beatsPerBar, clicksPerBeat,
          tempoMultiplier: tempoMultiplier);
    });
  }

  @override
  void stop() {
    print('remote stop');

    providerReader(nearbyDevicesProvider)
        .broadcastCommand(RemoteCommand.stopMetronome());

    super.stop();
  }
}
