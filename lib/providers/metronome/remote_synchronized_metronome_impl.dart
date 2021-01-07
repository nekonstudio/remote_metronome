// import '../remote/remote_command.dart';
// import '../remote/remote_synchronization.dart';
// import 'metronome.dart';
// import 'metronome_settings.dart';

// class RemoteSynchronizedMetronomeImpl extends Metronome {
//   final RemoteSynchronization synchronization;

//   RemoteSynchronizedMetronomeImpl(this.synchronization);

//   @override
//   void onStart(MetronomeSettings settings) {
//     print('Remote Synchronized Metronome start!');

//     synchronization.clientSynchonizedAction(
//       RemoteCommand.startMetronome(
//         settings.tempo,
//         settings.beatsPerBar,
//         settings.clicksPerBeat,
//         1.0, // TODO: remove
//       ),
//       () => super.onStart(settings),
//     );
//   }

//   @override
//   void onStop() {
//     print('remote stop');

//     synchronization.clientSynchonizedAction(
//       RemoteCommand.stopMetronome(),
//       () => super.onStop(),
//       instant: true,
//     );
//   }
// }
