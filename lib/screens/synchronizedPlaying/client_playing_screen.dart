import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:metronom/models/setlist.dart';
import 'package:metronom/providers/setlist_player/setlist_player.dart';
import 'package:metronom/screens/setlists/setlist_screen.dart';

import '../../providers/nearby/nearby_devices.dart';
import '../../providers/remote/remote_metronome_screen_controller.dart';
import '../../widgets/visualization.dart';

class ClientPlayingScreen extends StatelessWidget {
  var _isEndedByMe = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
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
          context.read(nearbyDevicesProvider).finish();
        }
        return isEnded;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Wspólne odtwarzanie'),
        ),
        body: ProviderListener<NearbyDevices>(
          provider: nearbyDevicesProvider,
          onChange: (context, nearbyDevices) async {
            print('changed');
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
          child: _RemoteMetronomePanel(),
        ),
      ),
    );
  }
}

class _RemoteMetronomePanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final controller = watch(remoteMetronomeScreenControllerProvider);
    if (!controller.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    final state = watch(remoteScreenStateProvider.state);

    SetlistPlayer player;
    if (state == _ScreenState.Setlist) {
      player = watch(setlistPlayerProvider(
          context.read(remoteScreenStateProvider).setlist));
    }

    final track = player?.currentTrack;

    final beatsPerBar = state == _ScreenState.SimpleMetronome
        ? controller.metronomeSettings.beatsPerBar
        : track.isComplex
            ? player.currentSection.settings.beatsPerBar
            : track.settings.beatsPerBar;

    final tempo = state == _ScreenState.SimpleMetronome
        ? controller.metronomeSettings.tempo
        : track.isComplex
            ? player.currentSection.settings.tempo
            : track.settings.tempo;

    // if (state == _ScreenState.Setlist) {}

    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        // mainAxisSize: MainAxisSize.max,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visualization(beatsPerBar),
          SizedBox(
            height: 50,
          ),
          Text(
            tempo.toString(),
            style: TextStyle(fontSize: 60),
            textAlign: TextAlign.center,
          ),
          if (state == _ScreenState.Setlist)
            Text(context.read(remoteScreenStateProvider).setlist.name),
        ],
      ),
    );
  }
}

enum _ScreenState { SimpleMetronome, Setlist }

class _ScreenStateNotifier extends StateNotifier<_ScreenState> {
  _ScreenStateNotifier(_ScreenState state) : super(state);

  Setlist _setlist;
  Setlist get setlist => _setlist;

  void setSimpleMetronomeState() => state = _ScreenState.SimpleMetronome;
  void setSetlistState(Setlist setlist) {
    _setlist = setlist;
    state = _ScreenState.Setlist;
  }
}

final remoteScreenStateProvider = StateNotifierProvider(
    (ref) => _ScreenStateNotifier(_ScreenState.SimpleMetronome));
