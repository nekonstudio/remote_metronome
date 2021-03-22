import '../providers/device_synchronization_mode_notifier_provider.dart';
import 'nearby_devices.dart';
import 'remote_commands/clock_sync_request_command.dart';
import 'remote_commands/clock_sync_response_command.dart';
import 'remote_commands/clock_sync_success_command.dart';
import 'remote_commands/remote_command.dart';

class RemoteSynchronization {
  final NearbyDevices nearbyDevices;
  final DeviceSynchronizationModeNotifier synchronizationMode;

  RemoteSynchronization(this.nearbyDevices, this.synchronizationMode);

  DateTime hostStartTime;

  int _clockSyncLatency;
  int _hostTimeDifference;
  int _targetSynchronizedDevicesCount;
  int _synchronizedDevicesCount = 0;

  int get clockSyncLatency => _clockSyncLatency;
  int get hostTimeDifference => _hostTimeDifference;

  void synchronize() {
    _targetSynchronizedDevicesCount = nearbyDevices.connectedDevicesCount;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final command = ClockSyncRequestCommand(timestamp);
    broadcastRemoteCommand(command);
  }

  void broadcastRemoteCommand(RemoteCommand command) {
    nearbyDevices.broadcastCommand(command);
  }

  void end() {
    _synchronizedDevicesCount = 0;
    synchronizationMode.changeMode(DeviceSynchronizationMode.None);
  }

  // Sender:    Host
  // Receiver:  Client
  void onClockSyncRequest(String hostEndpointId, int hostStartTimestamp) {
    print('Host start time: ${DateTime.fromMillisecondsSinceEpoch(hostStartTimestamp)}');
    print('Client start time: ${DateTime.now()}');

    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    final command = ClockSyncResponseCommand(hostStartTimestamp, currentTimestamp);

    _sendRemoteCommand(hostEndpointId, command);
  }

  // Sender:    Client
  // Receiver:  Host
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
      final command = ClockSyncRequestCommand(timestamp);
      _sendRemoteCommand(clientEndpointId, command);
    } else {
      print('Start time: $startTime');
      print('Client response time: $clientResponseTime');

      final remoteTimeDiff = clientResponseTime.difference(startTime).inMilliseconds;
      final timeDifference = (remoteTimeDiff >= 0)
          ? remoteTimeDiff - _clockSyncLatency.toInt()
          : remoteTimeDiff + _clockSyncLatency.toInt();

      print('Host clock sync success! Remote time difference: $timeDifference');

      final command = ClockSyncSuccessCommand(-timeDifference, _clockSyncLatency);
      _sendRemoteCommand(clientEndpointId, command);

      _synchronizedDevicesCount++;

      if (_synchronizedDevicesCount == _targetSynchronizedDevicesCount) {
        synchronizationMode.changeMode(DeviceSynchronizationMode.Host);
      }
    }
  }

  // Sender:    Host
  // Receiver:  Client
  void onClockSyncSuccess(int hostTimeDifference, int clockSyncLatency) {
    _hostTimeDifference = hostTimeDifference;
    _clockSyncLatency = clockSyncLatency;

    synchronizationMode.changeMode(DeviceSynchronizationMode.Client);

    print('Client clock sync success! Remote time difference: $hostTimeDifference');
  }

  void _sendRemoteCommand(String receiverEndpointId, RemoteCommand command) {
    nearbyDevices.sendRemoteCommand(receiverEndpointId, command);
  }
}
