import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'remote_command.dart';

abstract class RemoteCommandHandler {
  final Reader providerReader;

  const RemoteCommandHandler(this.providerReader);

  void handle(RemoteCommand command) {
    assert(command != null, 'Null command');

    switch (command.type) {
      case RemoteCommandType.ClockSyncRequest:
        onClockSyncRequest(command.parameters.first);
        break;

      case RemoteCommandType.ClockSyncResponse:
        final startTime = DateTime.fromMillisecondsSinceEpoch(
            int.parse(command.parameters[0]));
        final clientResponseTime = DateTime.fromMillisecondsSinceEpoch(
            int.parse(command.parameters[1]));
        onClockSyncResponse(startTime, clientResponseTime);
        break;

      case RemoteCommandType.ClockSyncSuccess:
        final remoteTimeDifference = int.parse(command.parameters[0]);
        onClockSyncSuccess(remoteTimeDifference);
        break;

      case RemoteCommandType.StartMetronome:
        final tempo = int.parse(command.parameters[0]);
        final beats = int.parse(command.parameters[1]);
        final clicks = int.parse(command.parameters[2]);
        final tempoMultiplier = double.parse(command.parameters[3]);
        final timestamp =
            DateTime.fromMillisecondsSinceEpoch(command.timestamp);

        onStartMetronome(tempo, beats, clicks, tempoMultiplier, timestamp);
        break;

      case RemoteCommandType.StopMetronome:
        onStopMetronome();
        break;

      default:
        print('Unhandled remote command: ${command.type}');
        break;
    }
  }

  void onClockSyncRequest(String hostStartTime);
  void onClockSyncResponse(DateTime startTime, DateTime clientResponseTime);
  void onClockSyncSuccess(int remoteTimeDifference);
  void onStartMetronome(int tempo, int beatsPerBar, int clicksPerBeat,
      double tempoMultiplier, DateTime timestamp);
  void onStopMetronome();
}
