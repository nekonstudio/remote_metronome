import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectingStatus extends StateNotifier<bool> {
  ConnectingStatus() : super(false);

  void changeStatus(bool isConnecting) => state = isConnecting;
}

final connectingStatusProvider =
    StateNotifierProvider((ref) => ConnectingStatus());

enum BluetoothConnectingResult { done, bondingError, socketError }

class BluetoothConnectionsManager with ChangeNotifier {
  final Map<BluetoothDevice, BluetoothConnection> _connections = {};
  final Reader providerReader;

  BluetoothConnectionsManager(this.providerReader);

  bool get hasConnections => _connections.length > 0;

  Future<BluetoothConnectingResult> connectTo(BluetoothDevice device) async {
    print('connectTo()');

    connectingStatus.changeStatus(true);

    var result = BluetoothConnectingResult.socketError;
    var isBonded = await FlutterBluetoothSerial.instance
            .getBondStateForAddress(device.address) ==
        BluetoothBondState.bonded;

    if (!isBonded) {
      isBonded = await FlutterBluetoothSerial.instance
          .bondDeviceAtAddress(device.address);
    }
    if (!isBonded) {
      result = BluetoothConnectingResult.bondingError;
    } else {
      try {
        final connection = await BluetoothConnection.toAddress(device.address);
        if (connection.isConnected) {
          _connections[device] = connection;
          result = BluetoothConnectingResult.done;
          notifyListeners();
        }
      } on Exception catch (e) {
        print('exception in connectTo(): $e');
      }
    }

    connectingStatus.changeStatus(false);

    return result;
  }

  void disconnect(BluetoothDevice device) {
    _connections[device]?.finish();
    if (_connections.remove(device) != null) {
      notifyListeners();
    }
  }

  bool isConnectedTo(BluetoothDevice device) {
    return _connections.containsKey(device);
  }

  ConnectingStatus get connectingStatus {
    return providerReader(connectingStatusProvider);
  }
}

final bluetoothConnectionsManagerProvider =
    ChangeNotifierProvider((ref) => BluetoothConnectionsManager(ref.read));
