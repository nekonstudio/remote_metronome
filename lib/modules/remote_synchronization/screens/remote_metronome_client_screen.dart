import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../metronome/providers/metronome_provider.dart';
import '../../setlists/providers/setlist_player_provider.dart';
import '../logic/nearby_devices.dart';
import '../providers/nearby_devices_provider.dart';
import '../providers/remote_screen_state_provider.dart';
import '../widgets/remote_metronome_panel.dart';

class RemoteMetronomeClientScreen extends StatefulWidget {
  final String hostName;

  RemoteMetronomeClientScreen(this.hostName);

  @override
  _RemoteMetronomeClientScreenState createState() => _RemoteMetronomeClientScreenState();
}

class _RemoteMetronomeClientScreenState extends State<RemoteMetronomeClientScreen> {
  var _isEndedByClient = false;

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
            if (_isEndedByClient) return;

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
          child: RemoteMetronomePanel(widget.hostName, () => _showEndDialog(context)),
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
      _isEndedByClient = true;

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
