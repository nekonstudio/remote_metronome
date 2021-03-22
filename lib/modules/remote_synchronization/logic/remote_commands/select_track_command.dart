import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../setlists/providers/setlist_player_provider.dart';
import '../../providers/remote_screen_state_provider.dart';
import 'remote_command.dart';
import 'remote_command_type.dart';

class SelectTrackCommand extends RemoteCommand {
  final int trackIndex;

  SelectTrackCommand(this.trackIndex) : super(RemoteCommandType.SelectTrack);

  factory SelectTrackCommand.fromJson(String source) =>
      SelectTrackCommand.fromMap(json.decode(source));

  factory SelectTrackCommand.fromMap(Map<String, dynamic> map) {
    return SelectTrackCommand(
      map['trackIndex'],
    );
  }

  @override
  void execute(Reader providerReader) {
    final remoteScreenState = providerReader(remoteScreenStateProvider);
    final setlist = remoteScreenState.setlist;

    if (setlist != null) {
      final setlistPlayer = providerReader(setlistPlayerProvider(setlist));

      setlistPlayer.selectTrack(trackIndex);
    }
  }

  @override
  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'trackIndex': trackIndex,
    };
  }
}
