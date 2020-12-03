import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BluetoothDevicesScanner with ChangeNotifier {
  bool _isScanning = false;

  Stream<List<BluetoothDevice>> scan({
    List<BluetoothDeviceType> deviceTypeFilter,
  }) async* {
    List<BluetoothDevice> devices = [];

    _isScanning = true;
    notifyListeners();

    await for (var result in FlutterBluetoothSerial.instance.startDiscovery()) {
      print(
          'new device: ${result.device.name} with type: ${result.device.type}');
      final addDevice = (BluetoothDevice device) {
        if (devices.indexWhere((value) => value.address == device.address) <
            0) {
          print('nie ma takiego, dodawanko na pewno');
          devices.add(device);
        }
        return devices;
      };

      if (deviceTypeFilter != null) {
        if (deviceTypeFilter.indexOf(result.device.type) >= 0) {
          yield addDevice(result.device);
        }
      } else {
        yield addDevice(result.device);
      }
    }

    _isScanning = false;
    notifyListeners();

    print('stream completed');
  }

  bool get isScanning {
    return _isScanning;
  }
}

final bluetoothDevicesScannerProvider =
    ChangeNotifierProvider.autoDispose((ref) => BluetoothDevicesScanner());
