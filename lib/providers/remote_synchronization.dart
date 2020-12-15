import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metronom/providers/nearby/nearby_devices.dart';
import 'package:metronom/providers/remoteCommand/remote_command.dart';

enum DeviceSynchronizationMode { Host, Client, None }

class RemoteSynchronization with ChangeNotifier {
  final Future<void> Function(RemoteCommand) sendRemoteCommand;

  RemoteSynchronization(this.sendRemoteCommand);

  var _mode = DeviceSynchronizationMode.None;
  int _remoteTimeDifference;

  DeviceSynchronizationMode get deviceMode => _mode;
  bool get isSynchronized => _mode != DeviceSynchronizationMode.None;

  Future<void> synchronize() async {
    sendRemoteCommand(RemoteCommand.clockSyncRequest(DateTime.now()));
  }

  void end() {
    _mode = DeviceSynchronizationMode.None;
    notifyListeners();
  }

  void onClockSyncRequest(String hostStartTime) {
    print(
        'Host start time: ${DateTime.fromMillisecondsSinceEpoch(int.parse(hostStartTime))}');
    print('Client start time: ${DateTime.now()}');
    sendRemoteCommand(
        RemoteCommand.clockSyncResponse(hostStartTime, DateTime.now()));
  }

  void onClockSyncResponse(DateTime startTime, DateTime clientResponseTime) {
    final latency = DateTime.now().difference(startTime).inMilliseconds / 2;

    print('Latency: ($latency ms)');

    if (latency > 12) {
      // perform clock sync as long as you get satisfying latency for reliable result
      print('To big latency, trying again');

      sendRemoteCommand(
        RemoteCommand.clockSyncRequest(DateTime.now()),
      );
    } else {
      print('Start time: $startTime');
      print('Client response time: $clientResponseTime');
      var remoteTimeDiff =
          clientResponseTime.difference(startTime).inMilliseconds;

      _remoteTimeDifference = (remoteTimeDiff >= 0)
          ? remoteTimeDiff - latency.toInt()
          : remoteTimeDiff + latency.toInt();

      print(
          'Host clock sync success! Remote time difference: $_remoteTimeDifference');

      sendRemoteCommand(
        RemoteCommand.clockSyncSuccess(-_remoteTimeDifference),
      );

      _mode = DeviceSynchronizationMode.Host;
      notifyListeners();
    }
  }

  void onClockSyncSuccess(int remoteTimeDifference) {
    _remoteTimeDifference = remoteTimeDifference;
    _mode = DeviceSynchronizationMode.Client;
    notifyListeners();
    print(
        'Client clock sync success! Remote time difference: $remoteTimeDifference');
  }

  void clientSynchonizedAction(RemoteCommand remoteCommand, Function action,
      {bool instant = false}) {
    print('hostStartTime: ${DateTime.now()}');
    sendRemoteCommand(remoteCommand);

    instant
        ? action()
        : Future.delayed(Duration(milliseconds: 500), () {
            print('HOST START! time:\t' + DateTime.now().toString());
            action();
          });
  }

  void hostSynchonizedAction(DateTime hostStartTime, Function action) async {
    print('hostStartTime: $hostStartTime');
    print('remoteTimeDifference: $_remoteTimeDifference');
    final latency = DateTime.now()
        .difference(
            hostStartTime.add(Duration(milliseconds: -_remoteTimeDifference)))
        .inMilliseconds;

    print('latency: $latency ms');

    final waitTime =
        hostStartTime.add(Duration(milliseconds: -_remoteTimeDifference + 500));

    print('currentTime =\t${DateTime.now()}');
    print('waitTime =\t\t$waitTime');

    await Future.doWhile(() => DateTime.now().isBefore(waitTime));

    final hostNowTime =
        DateTime.now().add(Duration(milliseconds: _remoteTimeDifference));
    print('CLIENT START! (host) time: $hostNowTime');
    print('CLIENT START! (client) time: ${DateTime.now()}');

    action();
  }
}

final synchronizationProvider = ChangeNotifierProvider(
  (ref) => RemoteSynchronization(
    ref.read(nearbyDevicesProvider).broadcastCommand,
  ),
);
