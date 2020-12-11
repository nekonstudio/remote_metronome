import 'dart:convert';
import 'dart:typed_data';

enum RemoteCommandType {
  ClockSyncRequest,
  ClockSyncResponse,
  ClockSyncSuccess,
  StartMetronome,
  StopMetronome,
  LatencyTest,
}

class RemoteCommand {
  final RemoteCommandType type;
  final List<String> parameters;
  int timestamp;

  RemoteCommand(this.type, {this.parameters, this.timestamp}) {
    timestamp ??= DateTime.now().millisecondsSinceEpoch;
    print(
        'RemoteCommand(): timestamp: ${DateTime.fromMillisecondsSinceEpoch(timestamp)}');
  }

  RemoteCommand.clockSyncRequest(DateTime startTime)
      : this(RemoteCommandType.ClockSyncRequest,
            parameters: [startTime.millisecondsSinceEpoch.toString()]);

  RemoteCommand.clockSyncResponse(String startTime, DateTime clientTime)
      : this(
          RemoteCommandType.ClockSyncResponse,
          parameters: [
            startTime,
            clientTime.millisecondsSinceEpoch.toString(),
          ],
        );

  RemoteCommand.clockSyncSuccess(int timeDiff)
      : this(RemoteCommandType.ClockSyncSuccess,
            parameters: [timeDiff.toString()]);

  RemoteCommand.startMetronome(
      int tempo, int beatsPerBar, int clicksPerBeat, double tempoMultiplier)
      : this(
          RemoteCommandType.StartMetronome,
          parameters: [
            tempo.toString(),
            beatsPerBar.toString(),
            clicksPerBeat.toString(),
            tempoMultiplier.toString(),
          ],
        );

  RemoteCommand.stopMetronome() : this(RemoteCommandType.StopMetronome);

  static RemoteCommand fromRawData(Uint8List data) {
    final str = utf8.decode(data);
    print('Raw data: $str');
    final values = str.split(';');

    final command =
        _enumFromString<RemoteCommandType>(values[0], RemoteCommandType.values);
    var params = values[1].split(',');
    if (params.first.isEmpty) {
      params = [];
    }
    final timestamp = int.parse(values[2]);

    final isValid = (command != null && params != null && timestamp != null);

    return isValid
        ? RemoteCommand(command, parameters: params, timestamp: timestamp)
        : null;
  }

  dynamic get parsedParameters {
    switch (type) {
      case RemoteCommandType.ClockSyncRequest:
        return DateTime.fromMillisecondsSinceEpoch(int.parse(parameters.first));
      case RemoteCommandType.ClockSyncResponse:
        // [0: Host sync start time, 1: Client response time]
        return List.generate(
          parameters.length,
          (index) => DateTime.fromMillisecondsSinceEpoch(
            int.parse(parameters[index]),
          ),
        );
      default:
        return null;
    }
  }

  Uint8List get bytes {
    final buffer = StringBuffer();
    buffer.write(_enumToString(type));
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
