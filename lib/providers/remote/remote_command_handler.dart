import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../metronome/metronome_base.dart';
import '../metronome/metronome_settings.dart';
import 'remote_command.dart';
import 'remote_metronome_screen_controller.dart';
import 'remote_synchronization.dart';

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
        final hostStartTime =
            DateTime.fromMillisecondsSinceEpoch(command.timestamp);

        synchronization.hostSynchonizedAction(
          hostStartTime,
          () => providerReader(metronomeProvider).start(
            MetronomeSettings(
              tempo,
              beats,
              clicks,
            ),
          ),
        );
        break;

      case RemoteCommandType.StopMetronome:
        providerReader(metronomeProvider).stop();
        break;

      case RemoteCommandType.SetMetronomeData:
        final tempo = int.parse(command.parameters[0]);
        final beats = int.parse(command.parameters[1]);
        providerReader(remoteMetronomeScreenControllerProvider)
            .initialize(tempo, beats);
        break;

      case RemoteCommandType.ChangeTempo:
        final tempo = int.parse(command.parameters[0]);
        providerReader(remoteMetronomeScreenControllerProvider).tempo = tempo;
        break;

      case RemoteCommandType.ChangeBeatsPerBar:
        final beatsPerBar = int.parse(command.parameters[0]);
        providerReader(remoteMetronomeScreenControllerProvider).beatsPerBar =
            beatsPerBar;
        break;

      default:
        print('Unhandled remote command: ${command.type}');
        break;
    }
  }
}
