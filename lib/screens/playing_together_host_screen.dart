import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../providers/nearby/nearby_devices.dart';
import '../providers/remoteCommand/remote_command.dart';
import '../providers/remoteCommand/role.dart';
import '../widgets/connected_nearby_devices_list.dart';
import 'simple_metronome_screen.dart';

class PlayingTogetherHostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('P O T Ę Ż N Y rebuild');
    context.read(nearbyDevicesProvider).advertise();

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista połączonych urządzeń'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          context.read(nearbyDevicesProvider).finish();
          return true;
        },
        child: Column(
          children: [
            LinearProgressIndicator(),
            Expanded(
              child: ConnectedNearbyDevicesList(),
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer(
        builder: (context, watch, child) {
          final hasConnections = watch(nearbyDevicesProvider).hasConnections;

          print('hasConnections? $hasConnections');

          return FloatingActionButton(
            backgroundColor:
                hasConnections ? Get.theme.accentColor : Colors.grey,
            child: child,
            onPressed: hasConnections
                ? () async {
                    context.read(nearbyDevicesProvider).stopAdvertising();
                    context.read(roleProvider).role = Role.Host;

                    // await
                    context.read(nearbyDevicesProvider).broadcastCommand(
                        RemoteCommand.clockSyncRequest(DateTime.now()));
                    // context.read(hostRemoteSyncExecutorProvider).clockSync();

                    Get.offAll(SimpleMetronomeScreen());
                  }
                : null,
          );
        },
        child: Icon(Icons.done),
      ),
    );
  }
}
