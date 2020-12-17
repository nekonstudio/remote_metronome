import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

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

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visualization(controller.beatsPerBar),
        Text(
          controller.tempo.toString(),
          style: TextStyle(fontSize: 60),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
