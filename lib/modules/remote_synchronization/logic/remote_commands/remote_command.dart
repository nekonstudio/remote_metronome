import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../utils/helpers/enum_string_converter.dart';
import 'clock_sync_request_command.dart';
import 'clock_sync_response_command.dart';
import 'clock_sync_success_command.dart';
import 'play_track_command.dart';
import 'remote_command_type.dart';
import 'select_next_section_command.dart';
import 'select_previous_section_command.dart';
import 'select_track_command.dart';
import 'set_metronome_settings_command.dart';
import 'set_setlist_command.dart';
import 'start_metronome_command.dart';
import 'stop_metronome_command.dart';
import 'stop_track_command.dart';

abstract class RemoteCommand {
  final RemoteCommandType type;

  RemoteCommand(this.type);

  factory RemoteCommand.createFromBytes(String senderId, Uint8List bytes) {
    final stringData = utf8.decode(bytes);
    final separatedStringValues = stringData.split(';');
    final commandType = EnumStringConverter.enumFromString<RemoteCommandType>(
        separatedStringValues[0], RemoteCommandType.values);
    final jsonParameters = _injectSenderIdToParameters(separatedStringValues[1], senderId);

    if (commandType == null || jsonParameters == null) {
      throw Exception('Invalid remote command');
    }

    RemoteCommand command;

    switch (commandType) {
      case RemoteCommandType.ClockSyncRequest:
        command = ClockSyncRequestCommand.fromJson(jsonParameters);
        break;
      case RemoteCommandType.ClockSyncResponse:
        command = ClockSyncResponseCommand.fromJson(jsonParameters);
        break;
      case RemoteCommandType.ClockSyncSuccess:
        command = ClockSyncSuccessCommand.fromJson(jsonParameters);
        break;
      case RemoteCommandType.StartMetronome:
        command = StartMetronomeCommand.fromJson(jsonParameters);
        break;
      case RemoteCommandType.StopMetronome:
        command = StopMetronomeCommand();
        break;
      case RemoteCommandType.SetMetronomeSettings:
        command = SetMetronomeSettingsCommand.fromJson(jsonParameters);
        break;
      case RemoteCommandType.SetSetlist:
        command = SetSetlistCommand.fromJson(jsonParameters);
        break;
      case RemoteCommandType.PlayTrack:
        command = PlayTrackCommand.fromJson(jsonParameters);
        break;
      case RemoteCommandType.StopTrack:
        command = StopTrackCommand();
        break;
      case RemoteCommandType.SelectTrack:
        command = SelectTrackCommand.fromJson(jsonParameters);
        break;
      case RemoteCommandType.SelectNextSection:
        command = SelectNextSectionCommand();
        break;
      case RemoteCommandType.SelectPreviousSection:
        command = SelectPreviousSectionCommand();
        break;
    }

    return command;
  }

  void execute(Reader providerReader);
  String toJson();

  Uint8List get bytes {
    final buffer = StringBuffer();
    buffer.write(EnumStringConverter.enumToString(type));
    buffer.write(';');
    buffer.write(toJson());

    return utf8.encode(buffer.toString());
  }

  static String _injectSenderIdToParameters(String parameters, String senderId) {
    if (parameters.isEmpty) return parameters;

    String output = parameters;
    final Map<String, dynamic> parametersMap = json.decode(parameters);
    if (parametersMap.containsKey('senderId')) {
      parametersMap['senderId'] = senderId;

      output = json.encode(parametersMap);
    }

    return output;
  }
}
