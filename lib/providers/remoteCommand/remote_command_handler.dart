import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metronom/providers/metronome/metronome.dart';
import 'package:metronom/providers/remote_synchronization.dart';

import 'remote_command.dart';

class RemoteCommandHandler {
  final Reader providerReader;

  RemoteCommandHandler(this.providerReader);

  void handle(RemoteCommand command) {
    assert(command != null, 'Null command');

    final synchronization = providerReader(synchronizationProvider);

    switch (command.type) {
      case RemoteCommandType.ClockSyncRequest:
        synchronization.onClockSyncRequest(command.parameters.first);
        break;

      case RemoteCommandType.ClockSyncResponse:
        final startTime = DateTime.fromMillisecondsSinceEpoch(
            int.parse(command.parameters[0]));
        final clientResponseTime = DateTime.fromMillisecondsSinceEpoch(
            int.parse(command.parameters[1]));
        synchronization.onClockSyncResponse(startTime, clientResponseTime);
        break;

      case RemoteCommandType.ClockSyncSuccess:
        final remoteTimeDifference = int.parse(command.parameters[0]);
        synchronization.onClockSyncSuccess(remoteTimeDifference);
        break;

      case RemoteCommandType.StartMetronome:
        final tempo = int.parse(command.parameters[0]);
        final beats = int.parse(command.parameters[1]);
        final clicks = int.parse(command.parameters[2]);
        final tempoMultiplier = double.parse(command.parameters[3]);
        final hostStartTime =
            DateTime.fromMillisecondsSinceEpoch(command.timestamp);

        synchronization.hostSynchonizedAction(
          hostStartTime,
          () => providerReader(metronomeProvider)
              .start(tempo, beats, clicks, tempoMultiplier: tempoMultiplier),
        );
        break;

      case RemoteCommandType.StopMetronome:
        providerReader(metronomeProvider).stop();
        break;

      default:
        print('Unhandled remote command: ${command.type}');
        break;
    }
  }
}
