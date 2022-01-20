import '../../../metronome/models/metronome_settings.dart';
import '../remote_synchronization.dart';
import 'remote_synchronized_metronome.dart';

class HostSynchronizedMetronome extends RemoteSynchronizedMetronome {
  HostSynchronizedMetronome(RemoteSynchronization synchronization) : super(synchronization);

  @override
  void startMetronome(MetronomeSettings settings) async {
    assert(synchronization.hostStartTime != null, 'synchronization.hostStartTime must be provided');

    final hostStartTime = synchronization.hostStartTime!;
    final hostTimeDifference = synchronization.hostTimeDifference!;
    final waitTime = hostStartTime.add(
      Duration(
        milliseconds: -hostTimeDifference +
            RemoteSynchronizedMetronome.commandExecutionDuration.inMilliseconds +
            (synchronization.clockSyncLatency! ~/ 2),
      ),
    );

    prepareSynchronizedStart(settings);

    await Future.doWhile(() => DateTime.now().isBefore(waitTime));

    runSynchronizedStart();
    synchronization.hostStartTime = null;
  }
}
