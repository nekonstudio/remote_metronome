import '../../models/setlist.dart';
import '../metronome/metronome_base.dart';
import '../remote/remote_command.dart';
import '../remote/remote_synchronization.dart';
import 'setlist_player.dart';

class RemoteSynchronizedSetlistPlayer extends SetlistPlayer {
  final RemoteSynchronization synchronization;

  RemoteSynchronizedSetlistPlayer(this.synchronization, Setlist setlist, MetronomeBase metronome)
      : super(setlist, metronome);

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

  @override
  void update() {
    synchronization.broadcastRemoteCommand(RemoteCommand.setSetlist(setlist));
    super.update();
  }
}
