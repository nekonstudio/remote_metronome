import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:metronom/bluetooth_message.dart';
import 'package:metronom/bluetooth_message_executor.dart';

class BluetoothManager with ChangeNotifier {
  BluetoothState _bluetoothState;
  StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
  StreamSubscription<BluetoothState> _btStateListener;
  StreamSubscription<BluetoothConnection> _incomingConnectionsListener;
  List<BluetoothDiscoveryResult> results = List<BluetoothDiscoveryResult>();
  Map<BluetoothDevice, BluetoothConnection> _connections = {};
  bool _isScanning = false;
  void Function(BluetoothState) _stateChangedCallback;

  BluetoothManager() {
    FlutterBluetoothSerial.instance.state.then((state) {
      _bluetoothState = state;
      notifyListeners();
      print('Bluetooth state: $state');

      if (state == BluetoothState.STATE_ON) {
        // _findConnectedDevices();
        _incomingConnectionsListener = FlutterBluetoothSerial.instance
            .onIncomingConnection()
            .listen((connection) {
          print("JAKIS NOWY CONNECTION MAMY WE FLUTTERU");

          BluetoothDevice device =
              BluetoothDevice(name: 'test', address: 'addressTest');
          _connections[device] = connection;

          notifyListeners();

          print('Connections size: ${_connections.length}');
          // connection.output.add(utf8.encode("Siemanko!"));
        });
      }
    }, onError: (error) {
      print('STATE ERROR!!!!');
    });

    _btStateListener =
        FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
      _bluetoothState = state;
      notifyListeners();

      _stateChangedCallback?.call(state);
      print('Bluetooth state changed to $state');
    });

    print('BluetoothManager() dla pewności');
  }

  void dispose() {
    _streamSubscription?.cancel();
    _btStateListener?.cancel();
    _incomingConnectionsListener?.cancel();
  }

  set _scanning(bool value) {
    _isScanning = value;
    notifyListeners();
  }

  bool get isScanning {
    return _isScanning;
  }

  Future<bool> enableBluetotoh() async {
    print('enableBluetotoh');
    return await FlutterBluetoothSerial.instance.requestEnable();
  }

  Future<bool> pair(BluetoothDevice device) async {
    return await FlutterBluetoothSerial.instance
        .bondDeviceAtAddress(device.address);
  }

  Future<bool> connect(BluetoothDevice device) async {
    var isSuccess = false;
    final connection = await BluetoothConnection.toAddress(device.address);
    if (connection.isConnected) {
      // connection.input.listen((data) {
      //   final message = BluetoothMessage.fromRawData(data);
      //   // await BluetoothMessageExecutor.awaitExecute(message.timestamp);

      //   callback(message);
      // });
      _connections[device] = connection;

      notifyListeners();
      isSuccess = true;
    }

    return isSuccess;
  }

  bool isConnected(BluetoothDevice device) {
    return _connections.containsKey(device);
  }

  int get connectedDevicesCount {
    return _connections.length;
  }

  Future<void> broadcastMessage(BluetoothMessage message) async {
    _connections.forEach((device, connection) {
      // message.timestamp = DateTime.now()
      //     .add(Duration(milliseconds: 5000))
      //     .millisecondsSinceEpoch;

      print('wysyłam wiadomość. data: ${DateTime.now().toIso8601String()}');
      connection.output.add(message.rawData);
      final storedTime = DateTime.now();
      connection.output.allSent.then((value) {
        final latency = DateTime.now().difference(storedTime).inMilliseconds;
        print('Wysłano w $latency ms');
      });
    });

    // await BluetoothMessageExecutor.awaitExecute(message.timestamp);
  }

  void setInputListenerCallback(void Function(BluetoothMessage) callback) {
    _connections.forEach((device, connection) {
      print('włączanko nasłuchiwanka');
      connection.input.listen((data) async {
        print('przyszła wiadomość. data: ${DateTime.now().toIso8601String()}');

        final message = BluetoothMessage.fromRawData(data);
        // await BluetoothMessageExecutor.awaitExecute(message.timestamp);

        callback(message);
      });
    });
  }

  void disconnect(BluetoothDevice device) {
    _connections[device].close();
    _connections.remove(device);

    notifyListeners();
  }

  Future<BluetoothState> waitForState() async {
    return await Future.delayed(
        Duration(milliseconds: 500), () => _bluetoothState);
  }

  BluetoothState get state {
    return _bluetoothState;
  }

  set stateChangedCallback(void Function(BluetoothState) callback) {
    _stateChangedCallback = callback;
  }

  Future<List<BluetoothDevice>> scanAvailableDevices(
      {List<BluetoothDeviceType> deviceTypeFilter,
      void Function(List<BluetoothDevice>) onDeviceListChanged}) async {
    List<BluetoothDevice> devices = [];

    _scanning = true;
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
      if (deviceTypeFilter != null) {
        if (deviceTypeFilter.indexOf(result.device.type) >= 0) {
          devices.add(result.device);
          onDeviceListChanged?.call(devices);
        }
      } else {
        devices.add(result.device);
        onDeviceListChanged?.call(devices);
      }
    }, onError: (error) => throw error);

    await _streamSubscription.asFuture();
    _scanning = false;

    return devices;
  }

  Future<void> _findConnectedDevices() async {
    final bondedDevices =
        await FlutterBluetoothSerial.instance.getBondedDevices();

    // BluetoothDevice device;
    // device.isConnected;

    await Future.forEach(bondedDevices, (device) async {
      if (device.type == BluetoothDeviceType.classic && device.isConnected) {
        print('${device.name}');
        _connections[device] =
            await BluetoothConnection.toAddress(device.address);
      }
    });

    print('Connected devices: ${_connections.length}');
    print(_connections);
  }
}
