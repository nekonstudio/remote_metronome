import '../remote_commands/play_track_command.dart';
import '../remote_commands/remote_command.dart';
import '../remote_commands/stop_track_command.dart';
import '../remote_synchronization.dart';
import 'client_synchronized_metronome.dart';

class ClientSynchronizedTrackMetronome extends ClientSynchronizedMetronome {
  ClientSynchronizedTrackMetronome(RemoteSynchronization synchronization) : super(synchronization);

  @override
  RemoteCommand createStartCommand(_) => PlayTrackCommand();

  @override
  RemoteCommand createStopCommand() => StopTrackCommand();
}
