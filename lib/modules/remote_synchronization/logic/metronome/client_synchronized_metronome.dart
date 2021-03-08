import 'package:flutter/foundation.dart';

import '../../../metronome/models/metronome_settings.dart';
import '../remote_command.dart';
import '../remote_synchronization.dart';
import 'remote_synchronized_metronome.dart';

class ClientSynchronizedMetronome extends RemoteSynchronizedMetronome {
  ClientSynchronizedMetronome(RemoteSynchronization synchronization) : super(synchronization);

  @override
  void startImplementation(MetronomeSettings settings) {
    synchronization.remoteActionNotifier.setActionState(true);
    synchronization.broadcastRemoteCommand(
      onStartCommand(settings),
    );

    prepareToRun(settings);

    print('1. HOST START! time:\t' + DateTime.now().toString());
    Future.delayed(
      Duration(milliseconds: 500),
      () {
        // _platformExecutionTimestamp = DateTime.now();
        print('2. HOST START! time:\t' + DateTime.now().toString());

        run();

        Future.delayed(
          Duration(milliseconds: 120),
          () => synchronization.remoteActionNotifier.setActionState(false),
        );
      },
    );
  }

  @override
  void stopImplementation() {
    synchronization.broadcastRemoteCommand(
      onStopCommand(),
    );

    invokePlatformMethod('stop');
  }

  @protected
  RemoteCommand onStartCommand(dynamic parameters) {
    assert(parameters is MetronomeSettings);

    return RemoteCommand.startMetronome(parameters);
  }

  @protected
  RemoteCommand onStopCommand() => RemoteCommand.stopMetronome();
}
