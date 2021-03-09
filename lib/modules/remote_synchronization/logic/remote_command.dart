import 'dart:convert';
import 'dart:typed_data';

import 'package:metronom/utils/helpers/enum_string_converter.dart';

import '../../metronome/models/metronome_settings.dart';
import '../../setlists/models/setlist.dart';

enum RemoteCommandType {
  ClockSyncRequest,
  ClockSyncResponse,
  ClockSyncSuccess,
  StartMetronome,
  StopMetronome,
  SetMetronomeSettings,
  SetSetlist,
  PlayTrack,
  StopTrack,
  SelectTrack,
  SelectNextSection,
  SelectPreviousSection,
  KeepConnectionAlive,
  LatencyTest,
}

class RemoteCommand {
  final RemoteCommandType type;
  final String jsonParameters;
  int timestamp;

  RemoteCommand(this.type, {this.jsonParameters, this.timestamp}) {
    timestamp ??= DateTime.now().millisecondsSinceEpoch;
    print('RemoteCommand(): timestamp: ${DateTime.fromMillisecondsSinceEpoch(timestamp)}');
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

  RemoteCommand.clockSyncSuccess(int timeDiff, int clockSyncLatency)
      : this(
          RemoteCommandType.ClockSyncSuccess,
          jsonParameters: json.encode([timeDiff, clockSyncLatency]),
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

  RemoteCommand.playTrack() : this(RemoteCommandType.PlayTrack);

  RemoteCommand.stopTrack() : this(RemoteCommandType.StopTrack);

  RemoteCommand.selectTrack(int index)
      : this(
          RemoteCommandType.SelectTrack,
          jsonParameters: json.encode(index),
        );

  RemoteCommand.selectNextSection() : this(RemoteCommandType.SelectNextSection);

  RemoteCommand.selectPreviousSection() : this(RemoteCommandType.SelectPreviousSection);

  static RemoteCommand fromRawData(Uint8List data) {
    final str = utf8.decode(data);
    print('Raw data: $str');

    final values = str.split(';');
    final command =
        EnumStringConverter.enumFromString<RemoteCommandType>(values[0], RemoteCommandType.values);
    final jsonParams = values[1];
    final timestamp = int.parse(values[2]);
    final isValid = (command != null && jsonParams != null && timestamp != null);

    return isValid
        ? RemoteCommand(command, jsonParameters: jsonParams, timestamp: timestamp)
        : null;
  }

  Uint8List get bytes {
    final buffer = StringBuffer();
    buffer.write(EnumStringConverter.enumToString(type));
    buffer.write(';');
    buffer.write(jsonParameters ?? '');
    buffer.write(';');
    buffer.write(timestamp ?? 0);

    return utf8.encode(buffer.toString());
  }
}
