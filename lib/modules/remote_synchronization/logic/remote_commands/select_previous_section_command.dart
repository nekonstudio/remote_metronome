import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../setlists/providers/setlist_player_provider.dart';
import '../../providers/remote_screen_state_provider.dart';
import 'remote_command.dart';
import 'remote_command_type.dart';

class SelectPreviousSectionCommand extends RemoteCommand {
  SelectPreviousSectionCommand()
      : super(RemoteCommandType.SelectPreviousSection);

  @override
  void execute(Reader providerReader) {
    final remoteScreenState =
        providerReader(remoteScreenStateProvider.notifier);
    final setlist = remoteScreenState.setlist;

    if (setlist != null) {
      final setlistPlayer = providerReader(setlistPlayerProvider(setlist));
      setlistPlayer.selectPreviousSection();
    }
  }

  @override
  String toJson() => '';
}
