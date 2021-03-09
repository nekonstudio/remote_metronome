import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../metronome/models/metronome_settings.dart';
import '../../metronome/providers/metronome_provider.dart';
import '../../setlists/models/setlist.dart';
import '../../setlists/providers/setlist_player_provider.dart';
import '../providers/remote_metronome_screen_controller_provider.dart';
import '../providers/remote_screen_state_provider.dart';
import '../providers/remote_synchronization_provider.dart';
import 'remote_command.dart';

// TODO: REFACTOR!
class RemoteCommandHandler {
  final Reader providerReader;

  RemoteCommandHandler(this.providerReader);

  void handle(String senderEndpointId, RemoteCommand command) {
    assert(command != null, 'Null command');

    final synchronization = providerReader(synchronizationProvider);

    // print('jsonParams: ${command.jsonParameters}');

    switch (command.type) {
      case RemoteCommandType.ClockSyncRequest:
        final hostStartTime = json.decode(command.jsonParameters) as int;
        synchronization.onClockSyncRequest(senderEndpointId, hostStartTime);
        break;

      case RemoteCommandType.ClockSyncResponse:
        final parameters = json.decode(command.jsonParameters) as List<dynamic>;
        final startTime = DateTime.fromMillisecondsSinceEpoch(parameters[0]);
        final clientResponseTime = DateTime.fromMillisecondsSinceEpoch(parameters[1]);
        synchronization.onClockSyncResponse(senderEndpointId, startTime, clientResponseTime);
        break;

      case RemoteCommandType.ClockSyncSuccess:
        final parameters = json.decode(command.jsonParameters) as List<dynamic>;
        final remoteTimeDifference = parameters[0] as int;
        final clockSyncLatency = parameters[1] as int;
        synchronization.onClockSyncSuccess(remoteTimeDifference, clockSyncLatency);
        break;

      case RemoteCommandType.StartMetronome:
        final metronomeSettings = MetronomeSettings.fromJson(command.jsonParameters);
        final hostStartTime = DateTime.fromMillisecondsSinceEpoch(command.timestamp);
        synchronization.hostStartTime = hostStartTime;

        providerReader(metronomeProvider).start(metronomeSettings);
        break;

      case RemoteCommandType.StopMetronome:
        providerReader(metronomeProvider).stop();
        break;

      case RemoteCommandType.SetMetronomeSettings:
        final metronomeSettings = MetronomeSettings.fromJson(command.jsonParameters);

        providerReader(remoteMetronomeScreenControllerProvider)
            .setMetronomeSettings(metronomeSettings);
        providerReader(remoteScreenStateProvider).setSimpleMetronomeState();
        break;

      case RemoteCommandType.SetSetlist:
        final setlist = Setlist.fromJson(command.jsonParameters);

        print(setlist);

        if (setlist.tracksCount > 0) {
          providerReader(remoteScreenStateProvider).setSetlistState(setlist);
        }

        break;

      case RemoteCommandType.PlayTrack:
        final setlist = providerReader(remoteScreenStateProvider).setlist;
        if (setlist != null) {
          final hostStartTime = DateTime.fromMillisecondsSinceEpoch(command.timestamp);
          final setlistPlayer = providerReader(setlistPlayerProvider(setlist));
          synchronization.hostStartTime = hostStartTime;

          setlistPlayer.play();
        }
        break;

      case RemoteCommandType.StopTrack:
        final setlist = providerReader(remoteScreenStateProvider).setlist;
        if (setlist != null) {
          final setlistPlayer = providerReader(setlistPlayerProvider(setlist));
          setlistPlayer.stop();
        }
        break;

      case RemoteCommandType.SelectTrack:
        final trackIndex = json.decode(command.jsonParameters) as int;
        final setlist = providerReader(remoteScreenStateProvider).setlist;
        if (setlist != null) {
          final setlistPlayer = providerReader(setlistPlayerProvider(setlist));
          setlistPlayer.selectTrack(trackIndex);
        }
        break;

      case RemoteCommandType.SelectNextSection:
        final setlist = providerReader(remoteScreenStateProvider).setlist;
        if (setlist != null) {
          final setlistPlayer = providerReader(setlistPlayerProvider(setlist));
          setlistPlayer.selectNextSection();
        }
        break;

      case RemoteCommandType.SelectPreviousSection:
        final setlist = providerReader(remoteScreenStateProvider).setlist;
        if (setlist != null) {
          final setlistPlayer = providerReader(setlistPlayerProvider(setlist));
          setlistPlayer.selectPreviousSection();
        }
        break;

      case RemoteCommandType.KeepConnectionAlive:
        // Do nothing
        break;

      default:
        print('Unhandled remote command: ${command.type}');
        break;
    }
  }
}
