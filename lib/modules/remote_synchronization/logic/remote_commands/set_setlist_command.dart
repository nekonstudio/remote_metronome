import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../setlists/models/setlist.dart';
import '../../providers/remote_screen_state_provider.dart';
import 'remote_command.dart';
import 'remote_command_type.dart';

class SetSetlistCommand extends RemoteCommand {
  final Setlist setlist;
  SetSetlistCommand(this.setlist) : super(RemoteCommandType.SetSetlist);

  factory SetSetlistCommand.fromJson(String source) =>
      SetSetlistCommand.fromMap(json.decode(source));

  factory SetSetlistCommand.fromMap(Map<String, dynamic> map) {
    return SetSetlistCommand(
      Setlist.fromMap(map['setlist']),
    );
  }

  @override
  void execute(Reader providerReader) {
    final remoteScreenState =
        providerReader(remoteScreenStateProvider.notifier);

    if (setlist.tracksCount > 0) {
      remoteScreenState.setSetlistState(setlist);
    }
  }

  @override
  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'setlist': setlist.toMap(),
    };
  }
}
