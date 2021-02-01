import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metronom/providers/metronome/metronome.dart';
import 'package:metronom/providers/metronome/metronome_interface.dart';
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

  final Stream<dynamic> platformLatencyStream =
      const EventChannel('com.example.metronom/platformLatencyChannel').receiveBroadcastStream();

  int _clockSyncLatency;
  int _platformLatency;
  DateTime _platformExecutionTimestamp;

  var _mode = DeviceSynchronizationMode.None;
  int _hostTimeDifference;
  int _targetSynchronizedDevicesCount;
  int _synchronizedDevicesCount = 0;
  Timer _keepConnectionAliveTimer;

  DateTime hostStartTime;

  int get clockSyncLatency => _clockSyncLatency;
  int get hostTimeDifference => _hostTimeDifference;

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
    _keepConnectionAliveTimer?.cancel();

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
    _clockSyncLatency = (DateTime.now().difference(startTime).inMilliseconds ~/ 2);

    print('Clock sync latency: ($_clockSyncLatency ms)');

    if (_clockSyncLatency > 15) {
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
          ? remoteTimeDiff - _clockSyncLatency.toInt()
          : remoteTimeDiff + _clockSyncLatency.toInt();

      print('Host clock sync success! Remote time difference: $timeDifference');

      final command = RemoteCommand.clockSyncSuccess(-timeDifference, _clockSyncLatency);
      _sendRemoteCommand(clientEndpointId, command);

      _synchronizedDevicesCount++;

      if (_synchronizedDevicesCount == _targetSynchronizedDevicesCount) {
        _mode = DeviceSynchronizationMode.Host;

        platformLatencyStream.listen(_setPlatformLatency);
        // _keepConnectionAliveTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        //   final command = RemoteCommand(RemoteCommandType.KeepConnectionAlive);
        //   broadcastRemoteCommand(command);
        // });
        notifyListeners();
      }
    }
  }

  void onClockSyncSuccess(int hostTimeDifference, int clockSyncLatency) {
    _hostTimeDifference = hostTimeDifference;
    _clockSyncLatency = clockSyncLatency;
    _mode = DeviceSynchronizationMode.Client;

    platformLatencyStream.listen(_setPlatformLatency);

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
      // _platformExecutionTimestamp = DateTime.now();
      // _metronomePlatformChannel.invokeMethod('syncStartPrepare');
      Future.delayed(
        Duration(milliseconds: 500),
        () {
          // print('HOST START! time:\t' + DateTime.now().toString());
          action();
          // _metronomePlatformChannel.invokeMethod('syncStart');
          Future.delayed(
            Duration(milliseconds: 120),
            () => remoteActionNotifier.setActionState(false),
          );
        },
      );
    }

    // action(); // TODO: remove
  }

  void hostSynchonizedAction(DateTime hostStartTime, Function action) async {
    print('hostStartTime: $hostStartTime');
    print('remoteTimeDifference: $_hostTimeDifference');
    final latency = DateTime.now()
        .difference(hostStartTime.add(Duration(milliseconds: -_hostTimeDifference)))
        .inMilliseconds;

    print('latency: $latency ms');

    final waitTime = hostStartTime
        .add(Duration(milliseconds: -_hostTimeDifference + 500 + (_clockSyncLatency ~/ 2) + 25));

    print('currentTime =\t${DateTime.now()}');
    print('currentTimeHost =\t${DateTime.now().add(Duration(milliseconds: _hostTimeDifference))}');
    print('waitTime =\t\t$waitTime');

    await Future.doWhile(() => DateTime.now().isBefore(waitTime));

    final hostNowTime = DateTime.now().add(Duration(milliseconds: _hostTimeDifference));
    print('CLIENT START! (host) time: $hostNowTime');
    print('CLIENT START! (client) time: ${DateTime.now()}');

    // _platformExecutionTimestamp = DateTime.now();
    action();
  }

  void _setPlatformLatency(dynamic value) {
    // print(value);
    // _platformLatency = DateTime.fromMillisecondsSinceEpoch(value)
    //     .difference(_platformExecutionTimestamp)
    //     .inMilliseconds;

    // print('platformLatency: $_platformLatency ms');
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
