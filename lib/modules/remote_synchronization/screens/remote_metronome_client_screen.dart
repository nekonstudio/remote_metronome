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
  _RemoteMetronomeClientScreenState createState() =>
      _RemoteMetronomeClientScreenState();
}

class _RemoteMetronomeClientScreenState
    extends State<RemoteMetronomeClientScreen> {
  var _isEndedByClient = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        ref.listen<NearbyDevices>(nearbyDevicesProvider,
            (_, nearbyDevices) async {
          if (_isEndedByClient) return;

          if (!nearbyDevices.hasConnections) {
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Zakończono tryb wspólnego odtwarzania'),
                content: Text('Gospodarz sesji zakończył połączenie'),
                actions: [
                  TextButton(onPressed: Get.back, child: Text('OK')),
                ],
              ),
            );
            Get.back();
          }
        });
        return WillPopScope(
          onWillPop: () async {
            return _showEndDialog(ref);
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text('Wspólne odtwarzanie'),
            ),
            body: RemoteMetronomePanel(
              widget.hostName,
              () => _showEndDialog(ref),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _showEndDialog(WidgetRef ref) async {
    final isEnded = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Zakończyć wspólne odtwarzanie?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Powrót'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Zakończ'),
          ),
        ],
      ),
    );
    if (isEnded) {
      _isEndedByClient = true;

      final state = ref.read(remoteScreenStateProvider);
      if (state == ScreenState.Setlist) {
        ref
            .read(
              setlistPlayerProvider(
                  ref.read(remoteScreenStateProvider.notifier).setlist),
            )
            .stop();
      } else {
        ref.read(metronomeProvider).stop();
      }

      ref.read(nearbyDevicesProvider).finish();
    }
    return isEnded;
  }
}
