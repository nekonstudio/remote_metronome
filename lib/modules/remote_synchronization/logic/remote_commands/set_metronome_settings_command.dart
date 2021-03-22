import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../metronome/models/metronome_settings.dart';
import '../../providers/remote_metronome_screen_controller_provider.dart';
import '../../providers/remote_screen_state_provider.dart';
import 'remote_command.dart';
import 'remote_command_type.dart';

class SetMetronomeSettingsCommand extends RemoteCommand {
  final MetronomeSettings metronomeSettings;

  SetMetronomeSettingsCommand(this.metronomeSettings)
      : super(RemoteCommandType.SetMetronomeSettings);

  factory SetMetronomeSettingsCommand.fromJson(String source) =>
      SetMetronomeSettingsCommand.fromMap(json.decode(source));

  factory SetMetronomeSettingsCommand.fromMap(Map<String, dynamic> map) {
    return SetMetronomeSettingsCommand(
      MetronomeSettings.fromMap(map['metronomeSettings']),
    );
  }

  @override
  void execute(Reader providerReader) {
    final remoteMetronomeScreenController = providerReader(remoteMetronomeScreenControllerProvider);
    remoteMetronomeScreenController.setMetronomeSettings(metronomeSettings);

    final remoteScreenState = providerReader(remoteScreenStateProvider);
    remoteScreenState.setSimpleMetronomeState();
  }

  @override
  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'metronomeSettings': metronomeSettings.toMap(),
    };
  }
}
