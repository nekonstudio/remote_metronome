import 'package:flutter/foundation.dart';

import '../../../metronome/models/metronome_settings.dart';
import '../../providers/remote_launch_indicator_controller_provider.dart';
import '../remote_commands/remote_command.dart';
import '../remote_commands/start_metronome_command.dart';
import '../remote_commands/stop_metronome_command.dart';
import '../remote_synchronization.dart';
import 'remote_synchronized_metronome.dart';

class ClientSynchronizedMetronome extends RemoteSynchronizedMetronome {
  final RemoteLaunchIndicatorController remoteLaunchIndicatorController;

  ClientSynchronizedMetronome(
    RemoteSynchronization synchronization,
    this.remoteLaunchIndicatorController,
  ) : super(synchronization);

  @override
  void startMetronome(MetronomeSettings settings) {
    remoteLaunchIndicatorController.activate();

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
