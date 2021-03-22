import '../../providers/remote_launch_indicator_controller_provider.dart';
import '../remote_commands/play_track_command.dart';
import '../remote_commands/remote_command.dart';
import '../remote_commands/stop_track_command.dart';
import '../remote_synchronization.dart';
import 'client_synchronized_metronome.dart';

class ClientSynchronizedTrackMetronome extends ClientSynchronizedMetronome {
  ClientSynchronizedTrackMetronome(
    RemoteSynchronization synchronization,
    RemoteLaunchIndicatorController remoteLaunchIndicatorController,
  ) : super(synchronization, remoteLaunchIndicatorController);

  @override
  RemoteCommand createStartCommand(_) => PlayTrackCommand();

  @override
  RemoteCommand createStopCommand() => StopTrackCommand();
}
