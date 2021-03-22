import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../metronome/providers/metronome_provider.dart';
import 'remote_command.dart';
import 'remote_command_type.dart';

class StopMetronomeCommand extends RemoteCommand {
  StopMetronomeCommand() : super(RemoteCommandType.StopMetronome);

  @override
  void execute(Reader providerReader) {
    final metronome = providerReader(metronomeProvider);

    metronome.stop();
  }

  @override
  String toJson() => '';
}
