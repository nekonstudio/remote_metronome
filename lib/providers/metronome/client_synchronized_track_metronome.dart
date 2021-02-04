import 'package:metronom/providers/metronome/client_synchronized_metronome.dart';
import 'package:metronom/providers/remote/remote_command.dart';
import 'package:metronom/providers/remote/remote_synchronization.dart';

class ClientSynchronizedTrackMetronome extends ClientSynchronizedMetronome {
  ClientSynchronizedTrackMetronome(RemoteSynchronization synchronization) : super(synchronization);

  @override
  RemoteCommand onStartCommand(_) => RemoteCommand.playTrack();

  @override
  RemoteCommand onStopCommand() => RemoteCommand.stopTrack();
}
