import '../../../metronome/models/metronome_settings.dart';
import '../remote_synchronization.dart';
import 'remote_synchronized_metronome.dart';

class HostSynchronizedMetronome extends RemoteSynchronizedMetronome {
  HostSynchronizedMetronome(RemoteSynchronization synchronization) : super(synchronization);

  @override
  void startMetronome(MetronomeSettings settings) {
    // TODO: write code such that it dont't need that assert
    assert(synchronization.hostStartTime != null,
        'synchronization.hostStartTime must be set before HostSynchronizedMetronome.start() call');

    final now = DateTime.now();
    final hostStartTime = synchronization.hostStartTime;
    final hostTimeDifference = synchronization.hostTimeDifference;
    final hostSTtoClientST = hostStartTime.add(Duration(milliseconds: -hostTimeDifference));

    print('clientStarTime:\t $now');
    print('hostStartTime:\t $hostStartTime');
    print('hostTimeDiff:\t $hostTimeDifference');
    print('hostSTtoClientST:\t $hostSTtoClientST');
    print('latency: $now -  $hostSTtoClientST');

    print('$now - ($hostStartTime + $hostTimeDifference)');

    final latency = now
        .difference(
          synchronization.hostStartTime.add(
            Duration(milliseconds: -hostTimeDifference),
          ),
        )
        .inMilliseconds;

    print('latency: $latency ms');

    final waitTime = synchronization.hostStartTime.add(Duration(
        milliseconds: -hostTimeDifference + 500 + (synchronization.clockSyncLatency ~/ 2)));

    prepareSynchronizedStart(settings);

    print(
        '1. CLIENT START! time:\t${DateTime.now().add(Duration(milliseconds: hostTimeDifference))}');

    Future.doWhile(() => DateTime.now().isBefore(waitTime)).then((_) {
      print(
          '2. CLIENT START! time:\t${DateTime.now().add(Duration(milliseconds: hostTimeDifference))}');
      runSynchronizedStart();

      synchronization.hostStartTime = null;
    });
  }
}
