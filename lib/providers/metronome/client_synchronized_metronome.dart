import 'package:flutter/material.dart';
import 'package:metronom/providers/metronome/metronome_settings.dart';
import 'package:metronom/providers/metronome/remote_synchronized_metronome.dart';
import 'package:metronom/providers/remote/remote_command.dart';
import 'package:metronom/providers/remote/remote_synchronization.dart';

class ClientSynchronizedMetronome extends RemoteSynchronizedMetronome {
  ClientSynchronizedMetronome(RemoteSynchronization synchronization) : super(synchronization);

  @override
  void onStart(MetronomeSettings settings) {
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
  void onStop() {
    synchronization.broadcastRemoteCommand(
      onStopCommand(),
    );

    super.onStop();
  }

  @protected
  RemoteCommand onStartCommand(dynamic parameters) {
    assert(parameters is MetronomeSettings);

    return RemoteCommand.startMetronome(parameters);
  }

  @protected
  RemoteCommand onStopCommand() => RemoteCommand.stopMetronome();
}