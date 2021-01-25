import 'package:metronom/models/setlist.dart';
import 'package:metronom/providers/remote/remote_command.dart';
import 'package:metronom/providers/remote/remote_synchronization.dart';
import 'package:metronom/providers/setlist_player/notifier_setlist_player.dart';

class RemoteSynchronizedNotifierSetlistPlayer extends NotifierSetlistPlayer {
  final RemoteSynchronization synchronization;

  RemoteSynchronizedNotifierSetlistPlayer(this.synchronization, Setlist setlist) : super(setlist);

  @override
  void play() {
    synchronization.clientSynchonizedAction(
      RemoteCommand.playTrack(),
      super.play,
    );
  }

  @override
  void stop() {
    synchronization.broadcastRemoteCommand(
      RemoteCommand.stopTrack(),
    );
    super.stop();
  }

  @override
  void selectTrack(int index) {
    if (currentTrackIndex != index) {
      synchronization.broadcastRemoteCommand(
        RemoteCommand.selectTrack(index),
      );
    }
    super.selectTrack(index);
  }

  @override
  void selectNextTrack() {
    super.selectNextTrack();
    synchronization.broadcastRemoteCommand(
      RemoteCommand.selectTrack(currentTrackIndex),
    );
  }

  @override
  void selectPreviousTrack() {
    super.selectPreviousTrack();
    synchronization.broadcastRemoteCommand(
      RemoteCommand.selectTrack(currentTrackIndex),
    );
  }

  @override
  void selectNextSection() {
    if (isPlaying || !currentTrack.isComplex) return;

    synchronization.broadcastRemoteCommand(RemoteCommand.selectNextSection());
    super.selectNextSection();
  }

  @override
  void selectPreviousSection() {
    if (isPlaying || !currentTrack.isComplex) return;

    synchronization.broadcastRemoteCommand(RemoteCommand.selectPreviousSection());
    super.selectPreviousSection();
  }
}
