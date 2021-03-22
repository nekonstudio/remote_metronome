import '../../../metronome/logic/metronome_base.dart';
import '../../../remote_synchronization/logic/remote_commands/select_next_section_command.dart';
import '../../../remote_synchronization/logic/remote_commands/select_previous_section_command.dart';
import '../../../remote_synchronization/logic/remote_commands/select_track_command.dart';
import '../../../remote_synchronization/logic/remote_commands/set_setlist_command.dart';
import '../../../remote_synchronization/logic/remote_synchronization.dart';
import '../../models/setlist.dart';
import 'setlist_player.dart';

class RemoteSynchronizedSetlistPlayer extends SetlistPlayer {
  final RemoteSynchronization synchronization;

  RemoteSynchronizedSetlistPlayer(this.synchronization, Setlist setlist, MetronomeBase metronome)
      : super(setlist, metronome);

  @override
  void selectTrack(int index) {
    if (currentTrackIndex != index) {
      synchronization.broadcastRemoteCommand(
        SelectTrackCommand(index),
      );
    }
    super.selectTrack(index);
  }

  @override
  void selectNextTrack() {
    super.selectNextTrack();
    synchronization.broadcastRemoteCommand(
      SelectTrackCommand(currentTrackIndex),
    );
  }

  @override
  void selectPreviousTrack() {
    super.selectPreviousTrack();
    synchronization.broadcastRemoteCommand(
      SelectTrackCommand(currentTrackIndex),
    );
  }

  @override
  void selectNextSection() {
    if (isPlaying || !currentTrack.isComplex) return;

    final command = SelectNextSectionCommand();
    synchronization.broadcastRemoteCommand(command);

    super.selectNextSection();
  }

  @override
  void selectPreviousSection() {
    if (isPlaying || !currentTrack.isComplex) return;

    final command = SelectPreviousSectionCommand();
    synchronization.broadcastRemoteCommand(command);

    super.selectPreviousSection();
  }

  @override
  void update() {
    final command = SetSetlistCommand(setlist);
    synchronization.broadcastRemoteCommand(command);

    super.update();
  }
}
