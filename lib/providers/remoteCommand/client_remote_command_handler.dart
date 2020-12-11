import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../metronome/metronome.dart';
import '../nearby/nearby_devices.dart';
import 'remote_command.dart';
import 'remote_command_handler.dart';

class ClientRemoteCommandHandler extends RemoteCommandHandler {
  ClientRemoteCommandHandler(Reader providerReader) : super(providerReader);

  int remoteTimeDifference; // in milliseconds

  @override
  void onClockSyncRequest(String hostStartTime) {
    print(
        'Host start time: ${DateTime.fromMillisecondsSinceEpoch(int.parse(hostStartTime))}');
    print('Client start time: ${DateTime.now()}');
    providerReader(nearbyDevicesProvider).broadcastCommand(
        RemoteCommand.clockSyncResponse(hostStartTime, DateTime.now()));
  }

  @override
  void onClockSyncResponse(DateTime startTime, DateTime clientResponseTime) {
    throw ('Client received illegal command: clockSyncResponse');
  }

  @override
  void onClockSyncSuccess(int remoteTimeDifference) {
    this.remoteTimeDifference = remoteTimeDifference;

    print(
        'Client clock sync success! Remote time difference: $remoteTimeDifference');
  }

  @override
  void onStartMetronome(int tempo, int beatsPerBar, int clicksPerBeat,
      double tempoMultiplier, DateTime timestamp) async {
    print('hostStartTime: $timestamp');
    print('remoteTimeDifference: $remoteTimeDifference');
    final latency = DateTime.now()
        .difference(
            timestamp.add(Duration(milliseconds: -remoteTimeDifference)))
        .inMilliseconds;

    print('latency: $latency ms');

    final waitTime =
        timestamp.add(Duration(milliseconds: -remoteTimeDifference + 500));

    print('currentTime =\t${DateTime.now()}');
    print('waitTime =\t\t$waitTime');

    await Future.doWhile(() => DateTime.now().isBefore(waitTime));

    final hostNowTime =
        DateTime.now().add(Duration(milliseconds: remoteTimeDifference));
    print('CLIENT START! (host) time: $hostNowTime');
    print('CLIENT START! (client) time: ${DateTime.now()}');
    providerReader(metronomeProvider).start(tempo, beatsPerBar, clicksPerBeat,
        tempoMultiplier: tempoMultiplier);
  }

  @override
  void onStopMetronome() {
    providerReader(metronomeProvider).stop();
  }
}
