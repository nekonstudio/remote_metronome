import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../nearby/nearby_devices.dart';
import 'remote_command.dart';
import 'remote_command_handler.dart';

class HostRemoteCommandHandler extends RemoteCommandHandler {
  HostRemoteCommandHandler(Reader providerReader) : super(providerReader);

  @override
  void onClockSyncRequest(String hostStartTime) {
    throw ('Host received illegal command: clockSyncRequest');
  }

  @override
  void onClockSyncResponse(DateTime startTime, DateTime clientResponseTime) {
    final latency = DateTime.now().difference(startTime).inMilliseconds / 2;

    print('Latency: ($latency ms)');

    if (latency > 12) {
      // perform clock sync as long as you get satisfying latency for reliable result
      print('To big latency, trying again');

      providerReader(nearbyDevicesProvider).broadcastCommand(
        RemoteCommand.clockSyncRequest(DateTime.now()),
      );
    } else {
      print('Start time: $startTime');
      print('Client response time: $clientResponseTime');
      var remoteTimeDiff =
          clientResponseTime.difference(startTime).inMilliseconds;

      remoteTimeDiff = (remoteTimeDiff >= 0)
          ? remoteTimeDiff - latency.toInt()
          : remoteTimeDiff + latency.toInt();

      print('Host clock sync success! Remote time difference: $remoteTimeDiff');

      providerReader(nearbyDevicesProvider).broadcastCommand(
        RemoteCommand.clockSyncSuccess(-remoteTimeDiff),
      );
    }
  }

  @override
  void onClockSyncSuccess(int remoteTimeDifference) {
    throw ('Host received illegal command: clockSyncSuccess');
  }

  @override
  void onStartMetronome(int tempo, int beatsPerBar, int clicksPerBeat,
      double tempoMultiplier, DateTime timestamp) {
    throw ('Host received illegal command: startMetronome');
  }

  @override
  void onStopMetronome() {
    throw ('Host received illegal command: stopMetronome');
  }
}
