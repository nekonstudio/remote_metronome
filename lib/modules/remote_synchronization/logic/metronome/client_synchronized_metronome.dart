import 'package:flutter/foundation.dart';

import '../../../metronome/models/metronome_settings.dart';
import '../remote_commands/remote_command.dart';
import '../remote_commands/start_metronome_command.dart';
import '../remote_commands/stop_metronome_command.dart';
import '../remote_synchronization.dart';
import 'remote_synchronized_metronome.dart';

class ClientSynchronizedMetronome extends RemoteSynchronizedMetronome {
  ClientSynchronizedMetronome(RemoteSynchronization synchronization) : super(synchronization);

  @override
  void startMetronome(MetronomeSettings settings) {
    // TODO: figure out better way to update UI outside logic code
    synchronization.remoteActionNotifier.setActionState(true);

    synchronization.broadcastRemoteCommand(
      createStartCommand(settings),
    );

    prepareSynchronizedStart(settings);

    print('1. HOST START! time:\t' + DateTime.now().toString());
    Future.delayed(
      Duration(milliseconds: 500),
      () {
        print('2. HOST START! time:\t' + DateTime.now().toString());

        runSynchronizedStart();

        Future.delayed(
          Duration(milliseconds: 120),
          () => synchronization.remoteActionNotifier.setActionState(false),
        );
      },
    );
  }

  @override
  void stopMetronome() {
    synchronization.broadcastRemoteCommand(
      createStopCommand(),
    );

    invokePlatformMethod('stop');
  }

  @protected
  RemoteCommand createStartCommand(dynamic parameters) {
    assert(parameters is MetronomeSettings);

    return StartMetronomeCommand(parameters);
  }

  @protected
  RemoteCommand createStopCommand() => StopMetronomeCommand();
}
