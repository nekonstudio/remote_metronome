import 'dart:convert';

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

    print('jsonParams: ${command.jsonParameters}');

    switch (command.type) {
      case RemoteCommandType.ClockSyncRequest:
        final hostStartTime = json.decode(command.jsonParameters) as int;
        synchronization.onClockSyncRequest(hostStartTime);
        break;

      case RemoteCommandType.ClockSyncResponse:
        final parameters = json.decode(command.jsonParameters) as List<dynamic>;
        final startTime = DateTime.fromMillisecondsSinceEpoch(parameters[0]);
        final clientResponseTime =
            DateTime.fromMillisecondsSinceEpoch(parameters[1]);
        synchronization.onClockSyncResponse(startTime, clientResponseTime);
        break;

      case RemoteCommandType.ClockSyncSuccess:
        final remoteTimeDifference = json.decode(command.jsonParameters) as int;
        synchronization.onClockSyncSuccess(remoteTimeDifference);
        break;

      case RemoteCommandType.StartMetronome:
        final metronomeSettings =
            MetronomeSettings.fromJson(command.jsonParameters);
        final hostStartTime =
            DateTime.fromMillisecondsSinceEpoch(command.timestamp);

        synchronization.hostSynchonizedAction(
          hostStartTime,
          () => providerReader(metronomeProvider).start(metronomeSettings),
        );
        break;

      case RemoteCommandType.StopMetronome:
        providerReader(metronomeProvider).stop();
        break;

      case RemoteCommandType.SetMetronomeSettings:
        final metronomeSettings =
            MetronomeSettings.fromJson(command.jsonParameters);

        providerReader(remoteMetronomeScreenControllerProvider)
            .setMetronomeSettings(metronomeSettings);
        break;

      default:
        print('Unhandled remote command: ${command.type}');
        break;
    }
  }
}
