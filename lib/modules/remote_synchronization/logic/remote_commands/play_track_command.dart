import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../setlists/providers/setlist_player_provider.dart';
import '../../providers/remote_screen_state_provider.dart';
import '../../providers/remote_synchronization_provider.dart';
import 'remote_command.dart';
import 'remote_command_type.dart';

class PlayTrackCommand extends RemoteCommand {
  PlayTrackCommand({DateTime hostStartTime}) : super(RemoteCommandType.PlayTrack) {
    _hostStartTime = hostStartTime ?? DateTime.now();
  }

  DateTime _hostStartTime;

  factory PlayTrackCommand.fromJson(String source) => PlayTrackCommand.fromMap(json.decode(source));

  factory PlayTrackCommand.fromMap(Map<String, dynamic> map) =>
      PlayTrackCommand(hostStartTime: DateTime.fromMillisecondsSinceEpoch(map['hostStartTime']));

  @override
  void execute(Reader providerReader) {
    final remoteScreenState = providerReader(remoteScreenStateProvider);
    final setlist = remoteScreenState.setlist;

    if (setlist != null) {
      final synchronization = providerReader(synchronizationProvider);
      synchronization.hostStartTime = _hostStartTime;

      final setlistPlayer = providerReader(setlistPlayerProvider(setlist));
      setlistPlayer.play();
    }
  }

  @override
  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'hostStartTime': _hostStartTime.millisecondsSinceEpoch,
    };
  }
}
