import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../setlists/providers/setlist_player_provider.dart';
import '../../providers/remote_screen_state_provider.dart';
import 'remote_command.dart';
import 'remote_command_type.dart';

class StopTrackCommand extends RemoteCommand {
  StopTrackCommand() : super(RemoteCommandType.StopTrack);

  @override
  void execute(Reader providerReader) {
    final remoteScreenState =
        providerReader(remoteScreenStateProvider.notifier);
    final setlist = remoteScreenState.setlist;

    if (setlist != null) {
      final setlistPlayer = providerReader(setlistPlayerProvider(setlist));
      setlistPlayer.stop();
    }
  }

  @override
  String toJson() => '';
}
