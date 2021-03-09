import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../widgets/visualization.dart';
import '../../metronome/providers/metronome_provider.dart';
import '../../setlists/logic/setlist_player/setlist_player_interface.dart';
import '../../setlists/providers/setlist_player_provider.dart';
import '../../setlists/widgets/animated_track_sections.dart';
import '../logic/nearby_devices.dart';
import '../providers/nearby_devices_provider.dart';
import '../providers/remote_metronome_screen_controller_provider.dart';
import '../providers/remote_screen_state_provider.dart';

// TODO: REFACTOR
class ClientPlayingScreen extends StatelessWidget {
  final String hostName;

  ClientPlayingScreen(this.hostName);

  var _isEndedByMe = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return _showEndDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Wspólne odtwarzanie'),
        ),
        body: ProviderListener<NearbyDevices>(
          provider: nearbyDevicesProvider,
          onChange: (context, nearbyDevices) async {
            if (_isEndedByMe) return;

            if (!nearbyDevices.hasConnections) {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Zakończono tryb wspólnego odtwarzania'),
                  content: Text('Gospodarz sesji zakończył połączenie'),
                  actions: [
                    FlatButton(onPressed: Get.back, child: Text('OK')),
                  ],
                ),
              );
              Get.back();
            }
          },
          child: _RemoteMetronomePanel(hostName, () => _showEndDialog(context)),
        ),
      ),
    );
  }

  Future<bool> _showEndDialog(BuildContext context) async {
    final isEnded = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Zakończyć wspólne odtwarzanie?'),
        content: Text('Gospodarz sesji zakończył połączenie'),
        actions: [
          FlatButton(
            onPressed: () => Get.back(result: false),
            child: Text('Powrót'),
          ),
          FlatButton(
            onPressed: () => Get.back(result: true),
            child: Text('Zakończ'),
          ),
        ],
      ),
    );
    if (isEnded) {
      _isEndedByMe = true;

      final state = context.read(remoteScreenStateProvider.state);
      if (state == ScreenState.Setlist) {
        context.read(setlistPlayerProvider(context.read(remoteScreenStateProvider).setlist)).stop();
      } else {
        context.read(metronomeProvider).stop();
      }

      context.read(nearbyDevicesProvider).finish();
    }
    return isEnded;
  }
}

class _RemoteMetronomePanel extends ConsumerWidget {
  final String hostName;
  final Function showEndDialogFunction;

  _RemoteMetronomePanel(this.hostName, this.showEndDialogFunction);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final controller = watch(remoteMetronomeScreenControllerProvider);
    if (!controller.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    final state = watch(remoteScreenStateProvider.state);

    SetlistPlayerInterface player;
    if (state == ScreenState.Setlist) {
      player = watch(setlistPlayerProvider(context.read(remoteScreenStateProvider).setlist));
    }

    final track = player?.currentTrack;

    final beatsPerBar = state == ScreenState.SimpleMetronome
        ? controller.metronomeSettings.beatsPerBar
        : track.isComplex
            ? player.currentSection.settings.beatsPerBar
            : track.settings.beatsPerBar;

    final tempo = state == ScreenState.SimpleMetronome
        ? controller.metronomeSettings.tempo
        : track.isComplex
            ? player.currentSection.settings.tempo
            : track.settings.tempo;

    return Padding(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              RichText(
                text: TextSpan(
                  text: 'Odtwarzaniem zarządza ',
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                      text: hostName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // Text('Odtwarzaniem zarządza $hostName'),
              SizedBox(
                height: 50,
              ),
              Visualization(beatsPerBar),
              SizedBox(
                height: 30,
              ),
              Text(
                tempo.toString(),
                style: TextStyle(fontSize: 60),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              if (state == ScreenState.Setlist)
                Text(
                  '${context.read(remoteScreenStateProvider).setlist.name} - ${track.name}',
                  style: TextStyle(fontSize: 16),
                ),
              SizedBox(
                height: 30,
              ),
              if (state == ScreenState.Setlist && track.isComplex)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  color: Colors.black38,
                  child: AnimatedTrackSections(
                    player,
                    track.sections,
                  ),
                ),
            ],
          ),
          RaisedButton(
            onPressed: () async {
              final isEnded = await showEndDialogFunction();
              if (isEnded) {
                Get.back();
              }
              // context.read(nearbyDevicesProvider).finish();
            },
            child: Text('Zakończ'),
          ),
        ],
      ),
    );
  }
}
