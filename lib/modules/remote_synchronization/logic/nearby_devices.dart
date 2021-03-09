import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_connections/nearby_connections.dart';

import 'remote_command.dart';
import 'remote_command_handler.dart';

class NearbyDeviceInfo {
  final String endpointId;
  final String name;

  NearbyDeviceInfo(this.endpointId, this.name);
}

class NearbyDevices with ChangeNotifier {
  final List<NearbyDeviceInfo> _connectedDevices = [];
  final RemoteCommandHandler _receivedDataHandler;

  NearbyDevices(Reader providerReader)
      : _receivedDataHandler = RemoteCommandHandler(providerReader);

  var _isAdvertising = false;
  var _isDiscovering = false;
  String _lastDisconnectedDeviceName;

  List<String> get connectedDevicesList =>
      _connectedDevices.map((deviceInfo) => deviceInfo.name).toList();

  int get connectedDevicesCount => _connectedDevices.length;
  bool get hasConnections => _connectedDevices.isNotEmpty;

  String get lastDisconnectedDeviceName => _lastDisconnectedDeviceName;

  void dispose() {
    super.dispose();

    print('nearby dispose');

    stopAdvertising();
    stopDiscovery();

    for (final device in _connectedDevices) {
      Nearby().disconnectFromEndpoint(device.endpointId);
    }

    _connectedDevices.clear();
  }

  void finish() {
    stopAdvertising();
    stopDiscovery();

    for (final device in _connectedDevices) {
      Nearby().disconnectFromEndpoint(device.endpointId);
    }

    _connectedDevices.clear();

    notifyListeners();
  }

  Future<bool> advertise() async {
    if (_isAdvertising) return false;

    return _isAdvertising = await Nearby().startAdvertising(
      await _myDeviceName,
      Strategy.P2P_STAR,
      onConnectionInitiated: _onConnectionInitiated,
      onConnectionResult: _onConnectionResult,
      onDisconnected: _onDisconnected,
      serviceId: 'com.example.metronom',
    );
  }

  void stopAdvertising() {
    if (_isAdvertising) {
      Nearby().stopAdvertising();
      _isAdvertising = false;
    }
  }

  Future<bool> discover() async {
    if (_isDiscovering) return false;
    Nearby().askLocationPermission();

    return _isDiscovering = await Nearby().startDiscovery(await _myDeviceName, Strategy.P2P_STAR,
        onEndpointFound: (endpointId, endpointName, serviceId) async {
      stopDiscovery();
      Nearby().requestConnection(
        await _myDeviceName,
        endpointId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
    }, onEndpointLost: (endpointId) {}, serviceId: "com.example.metronom");
  }

  void stopDiscovery() {
    if (_isDiscovering) {
      Nearby().stopDiscovery();
      _isDiscovering = false;
    }
  }

  Future<void> broadcastCommand(RemoteCommand command) async {
    _connectedDevices.forEach((deviceInfo) {
      sendRemoteCommand(deviceInfo.endpointId, command);
    });
  }

  Future<void> sendRemoteCommand(String receiverEndpointId, RemoteCommand command) async {
    await Nearby().sendBytesPayload(receiverEndpointId, command.bytes);
  }

  Future<String> get _myDeviceName async => FlutterBluetoothSerial.instance.name;

  void _onConnectionInitiated(String endpointId, ConnectionInfo connectionInfo) async {
    print('connectionInfo.endpointName: ${connectionInfo.endpointName}');
    final isAccepted = await Nearby().acceptConnection(
      endpointId,
      onPayLoadRecieved: (endpointId, payload) {
        print('message recived');

        _receivedDataHandler.handle(endpointId, RemoteCommand.fromRawData(payload.bytes));
      },
    );

    if (isAccepted) {
      _connectedDevices.add(
        NearbyDeviceInfo(endpointId, connectionInfo.endpointName),
      );

      notifyListeners();
    }
  }

  void _onConnectionResult(String endpointId, Status status) {
    if (status != Status.CONNECTED) {
      _connectedDevices.removeWhere((element) => element.endpointId == endpointId);
      notifyListeners();
    }
  }

  void _onDisconnected(String endpointId) async {
    final lastDeviceIndex =
        _connectedDevices.indexWhere((element) => element.endpointId == endpointId);

    if (lastDeviceIndex >= 0) {
      _lastDisconnectedDeviceName = _connectedDevices.elementAt(lastDeviceIndex).name;

      _connectedDevices.removeAt(lastDeviceIndex);
      notifyListeners();
    }
  }
}
