import 'dart:convert';
import 'dart:typed_data';

enum BluetoothCommand { Play, Stop, LatencyTest, ClockSync }

class BluetoothMessage {
  final BluetoothCommand command;
  final List<String> parameters;

  int timestamp;

  BluetoothMessage(this.command, {this.parameters, this.timestamp});

  static BluetoothMessage fromRawData(Uint8List data) {
    final str = utf8.decode(data);
    // print('Raw data: $str');
    final values = str.split(';');

    final command =
        _enumFromString<BluetoothCommand>(values[0], BluetoothCommand.values);
    var params = values[1].split(',');
    if (params.first.isEmpty) {
      params = [];
    }
    final timestamp = int.parse(values[2]);

    final isValid = (command != null && params != null && timestamp != null);

    return isValid
        ? BluetoothMessage(command, parameters: params, timestamp: timestamp)
        : null;
  }

  Uint8List get rawData {
    final buffer = StringBuffer();
    buffer.write(_enumToString(command));
    buffer.write(';');

    if (parameters != null) {
      for (var i = 0; i < parameters.length; ++i) {
        buffer.write(parameters[i]);
        if (i < parameters.length - 1) {
          buffer.write(',');
        }
      }
    }

    buffer.write(';');
    buffer.write(timestamp ?? 0);

    return utf8.encode(buffer.toString());
  }

  static String _enumToString(Object o) => o.toString().split('.').last;

  static T _enumFromString<T>(String key, List<T> values) =>
      values.firstWhere((v) => key == _enumToString(v), orElse: () => null);
}
