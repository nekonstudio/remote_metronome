import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metronom/providers/metronome/metronome_settings.dart';

import '../nearby/nearby_devices.dart';
import 'remote_command.dart';

enum DeviceSynchronizationMode { Host, Client, None }

class RemoteActionNotifier extends StateNotifier<bool> {
  RemoteActionNotifier(bool state) : super(state);

  void setActionState(bool value) => state = value;
}

class RemoteSynchronization with ChangeNotifier {
  final NearbyDevices nearbyDevices;

  RemoteSynchronization(this.nearbyDevices);

  final remoteActionNotifier = RemoteActionNotifier(false);
  MetronomeSettings Function() simpleMetronomeSettingsGetter;

  var _mode = DeviceSynchronizationMode.None;
  int _hostTimeDifference;

  int _targetSynchronizedDevicesCount;
  int _synchronizedDevicesCount = 0;

  DeviceSynchronizationMode get deviceMode => _mode;
  bool get isSynchronized => _mode != DeviceSynchronizationMode.None;

  void synchronize() {
    _targetSynchronizedDevicesCount = nearbyDevices.connectedDevicesCount;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final command = RemoteCommand.clockSyncRequest(timestamp);
    broadcastRemoteCommand(command);
  }

  void broadcastRemoteCommand(RemoteCommand command) {
    nearbyDevices.broadcastCommand(command);
  }

  void end() {
    _synchronizedDevicesCount = 0;
    _mode = DeviceSynchronizationMode.None;
    notifyListeners();
  }

  void onClockSyncRequest(String hostEndpointId, int hostStartTime) {
    print('Host start time: ${DateTime.fromMillisecondsSinceEpoch(hostStartTime)}');
    print('Client start time: ${DateTime.now()}');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final command = RemoteCommand.clockSyncResponse(hostStartTime, timestamp);

    _sendRemoteCommand(hostEndpointId, command);
  }

  void onClockSyncResponse(
    String clientEndpointId,
    DateTime startTime,
    DateTime clientResponseTime,
  ) {
    final latency = DateTime.now().difference(startTime).inMilliseconds / 2;

    print('Latency: ($latency ms)');

    if (latency > 15) {
      // perform clock sync as long as you get satisfying latency for reliable result
      print('To big latency, trying again');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final command = RemoteCommand.clockSyncRequest(timestamp);
      _sendRemoteCommand(clientEndpointId, command);
    } else {
      print('Start time: $startTime');
      print('Client response time: $clientResponseTime');

      final remoteTimeDiff = clientResponseTime.difference(startTime).inMilliseconds;
      final timeDifference = (remoteTimeDiff >= 0)
          ? remoteTimeDiff - latency.toInt()
          : remoteTimeDiff + latency.toInt();

      print('Host clock sync success! Remote time difference: $timeDifference');

      final command = RemoteCommand.clockSyncSuccess(-timeDifference);
      _sendRemoteCommand(clientEndpointId, command);

      _synchronizedDevicesCount++;

      if (_synchronizedDevicesCount == _targetSynchronizedDevicesCount) {
        _mode = DeviceSynchronizationMode.Host;
        notifyListeners();
      }
    }
  }

  void onClockSyncSuccess(int hostTimeDifference) {
    _hostTimeDifference = hostTimeDifference;
    _mode = DeviceSynchronizationMode.Client;

    notifyListeners();
    print('Client clock sync success! Remote time difference: $hostTimeDifference');
  }

  void clientSynchonizedAction(RemoteCommand remoteCommand, Function action,
      {bool instant = false}) {
    print('hostStartTime: ${DateTime.now()}');
    broadcastRemoteCommand(remoteCommand);

    if (instant) {
      action();
    } else {
      remoteActionNotifier.setActionState(true);
      Future.delayed(
        Duration(milliseconds: 500),
        () {
          print('HOST START! time:\t' + DateTime.now().toString());
          action();
          Future.delayed(
            Duration(milliseconds: 120),
            () => remoteActionNotifier.setActionState(false),
          );
        },
      );
    }
  }

  void hostSynchonizedAction(DateTime hostStartTime, Function action) async {
    print('hostStartTime: $hostStartTime');
    print('remoteTimeDifference: $_hostTimeDifference');
    final latency = DateTime.now()
        .difference(hostStartTime.add(Duration(milliseconds: -_hostTimeDifference)))
        .inMilliseconds;

    print('latency: $latency ms');

    final waitTime = hostStartTime.add(Duration(milliseconds: -_hostTimeDifference + 500));

    print('currentTime =\t${DateTime.now()}');
    print('waitTime =\t\t$waitTime');

    await Future.doWhile(() => DateTime.now().isBefore(waitTime));

    final hostNowTime = DateTime.now().add(Duration(milliseconds: _hostTimeDifference));
    print('CLIENT START! (host) time: $hostNowTime');
    print('CLIENT START! (client) time: ${DateTime.now()}');

    action();
  }

  void _sendRemoteCommand(String receiverEndpointId, RemoteCommand command) {
    nearbyDevices.sendRemoteCommand(receiverEndpointId, command);
  }
}

final synchronizationProvider = ChangeNotifierProvider(
  (ref) => RemoteSynchronization(ref.read(nearbyDevicesProvider)),
);

StateNotifierProvider<RemoteActionNotifier> remoteActionNotifierProvider =
    StateNotifierProvider<RemoteActionNotifier>(
  (ref) => ref.read(synchronizationProvider).remoteActionNotifier,
);
