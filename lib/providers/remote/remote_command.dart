import 'dart:convert';
import 'dart:typed_data';

import 'package:metronom/models/setlist.dart';
import 'package:metronom/providers/metronome/metronome_settings.dart';

enum RemoteCommandType {
  ClockSyncRequest,
  ClockSyncResponse,
  ClockSyncSuccess,
  StartMetronome,
  StopMetronome,
  SetMetronomeSettings,
  SetSetlist,
  SelectTrack,
  LatencyTest,
}

class RemoteCommand {
  final RemoteCommandType type;
  final String jsonParameters;
  int timestamp;

  RemoteCommand(this.type, {this.jsonParameters, this.timestamp}) {
    timestamp ??= DateTime.now().millisecondsSinceEpoch;
    print(
        'RemoteCommand(): timestamp: ${DateTime.fromMillisecondsSinceEpoch(timestamp)}');
  }

  RemoteCommand.clockSyncRequest(int startTime)
      : this(
          RemoteCommandType.ClockSyncRequest,
          jsonParameters: json.encode(startTime),
        );

  RemoteCommand.clockSyncResponse(int startTime, int clientTime)
      : this(
          RemoteCommandType.ClockSyncResponse,
          jsonParameters: json.encode([
            startTime,
            clientTime,
          ]),
        );

  RemoteCommand.clockSyncSuccess(int timeDiff)
      : this(
          RemoteCommandType.ClockSyncSuccess,
          jsonParameters: json.encode(timeDiff),
        );

  RemoteCommand.startMetronome(MetronomeSettings settings)
      : this(
          RemoteCommandType.StartMetronome,
          jsonParameters: settings.toJson(),
        );

  RemoteCommand.stopMetronome() : this(RemoteCommandType.StopMetronome);

  RemoteCommand.setMetronomeSettings(MetronomeSettings settings)
      : this(
          RemoteCommandType.SetMetronomeSettings,
          jsonParameters: settings.toJson(),
        );

  RemoteCommand.setSetlist(Setlist setlist)
      : this(
          RemoteCommandType.SetSetlist,
          jsonParameters: setlist.toJson(),
        );

  RemoteCommand.selectTrack(int index)
      : this(
          RemoteCommandType.SelectTrack,
          jsonParameters: json.encode(index),
        );

  static RemoteCommand fromRawData(Uint8List data) {
    final str = utf8.decode(data);
    print('Raw data: $str');
    final values = str.split(';');

    final command =
        _enumFromString<RemoteCommandType>(values[0], RemoteCommandType.values);

    final jsonParams = values[1];

    print('jsonParams robienie: $jsonParams');

    final timestamp = int.parse(values[2]);

    final isValid =
        (command != null && jsonParams != null && timestamp != null);

    return isValid
        ? RemoteCommand(command,
            jsonParameters: jsonParams, timestamp: timestamp)
        : null;
  }

  Uint8List get bytes {
    final buffer = StringBuffer();
    buffer.write(_enumToString(type));
    buffer.write(';');
    buffer.write(jsonParameters ?? '');
    buffer.write(';');
    buffer.write(timestamp ?? 0);

    return utf8.encode(buffer.toString());
  }

  static String _enumToString(Object o) => o.toString().split('.').last;

  static T _enumFromString<T>(String key, List<T> values) =>
      values.firstWhere((v) => key == _enumToString(v), orElse: () => null);
}
