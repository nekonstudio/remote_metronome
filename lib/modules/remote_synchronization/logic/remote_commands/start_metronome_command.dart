import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../metronome/models/metronome_settings.dart';
import '../../../metronome/providers/metronome_provider.dart';
import '../../providers/remote_synchronization_provider.dart';
import 'remote_command.dart';
import 'remote_command_type.dart';

class StartMetronomeCommand extends RemoteCommand {
  final MetronomeSettings metronomeSettings;

  StartMetronomeCommand(this.metronomeSettings, {DateTime hostStartTime})
      : super(RemoteCommandType.StartMetronome) {
    _hostStartTime = hostStartTime ?? DateTime.now();
  }

  DateTime _hostStartTime;

  @override
  void execute(Reader providerReader) {
    final synchronization = providerReader(synchronizationProvider);
    synchronization.hostStartTime = _hostStartTime;

    final metronome = providerReader(metronomeProvider);
    metronome.start(metronomeSettings);
  }

  factory StartMetronomeCommand.fromJson(String source) =>
      StartMetronomeCommand.fromMap(json.decode(source));

  factory StartMetronomeCommand.fromMap(Map<String, dynamic> map) {
    return StartMetronomeCommand(
      MetronomeSettings.fromMap(map['metronomeSettings']),
      hostStartTime: DateTime.fromMillisecondsSinceEpoch(map['hostStartTime']),
    );
  }

  @override
  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'metronomeSettings': metronomeSettings.toMap(),
      'hostStartTime': _hostStartTime.millisecondsSinceEpoch,
    };
  }
}
