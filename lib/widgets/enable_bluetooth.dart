import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class EnableBluetooth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Włącz Bluetooth, aby skorzystać z funkcjonalności'),
          SizedBox(
            height: 10,
          ),
          RaisedButton(
            onPressed: FlutterBluetoothSerial.instance.requestEnable,
            child: Text('Włącz'),
          ),
        ],
      ),
    );
  }
}
