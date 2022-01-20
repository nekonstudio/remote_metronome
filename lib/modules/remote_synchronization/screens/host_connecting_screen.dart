import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../metronome/screens/simple_metronome_screen.dart';
import '../providers/device_synchronization_mode_notifier_provider.dart';
import '../providers/nearby_devices_provider.dart';
import '../providers/remote_synchronization_provider.dart';
import '../widgets/connected_nearby_devices_list.dart';

class HostConnectingScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(nearbyDevicesProvider).advertise();

    ref.listen<DeviceSynchronizationModeNotifier>(
        deviceSynchronizationModeNotifierProvider,
        (_, deviceSynchronizationModeNotifier) {
      if (deviceSynchronizationModeNotifier.isSynchronized) {
        Get.back();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista połączonych urządzeń'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          ref.read(nearbyDevicesProvider).finish();
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
        builder: (context, ref, child) {
          final hasConnections =
              ref.watch(nearbyDevicesProvider).hasConnections;

          print('hasConnections? $hasConnections');

          return FloatingActionButton(
            backgroundColor:
                hasConnections ? Get.theme.colorScheme.secondary : Colors.grey,
            child: child,
            onPressed: hasConnections
                ? () async {
                    ref.read(nearbyDevicesProvider).stopAdvertising();

                    ref.read(synchronizationProvider).synchronize();
                    await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Proszę czekać...'),
                            content: ListTile(
                              leading: CircularProgressIndicator(),
                              title: Text('Trwa synchronizacja'),
                            ),
                          );
                        });

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
