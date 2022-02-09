import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../providers/device_synchronization_mode_notifier_provider.dart';
import '../providers/nearby_devices_provider.dart';
import 'remote_metronome_client_screen.dart';

class ClientConnectingScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(nearbyDevicesProvider).discover();

    ref.listen<DeviceSynchronizationModeNotifier>(
      deviceSynchronizationModeNotifierProvider,
      (previous, next) {
        if (next.mode == DeviceSynchronizationMode.Client) {
          final hostName =
              ref.read(nearbyDevicesProvider).connectedDevicesList.first;
          Get.off(RemoteMetronomeClientScreen(hostName));
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Wspólne odtwarzanie'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          ref.read(nearbyDevicesProvider).finish();
          return true;
        },
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(
                height: 20,
              ),
              Consumer(
                builder: (context, ref, child) {
                  final nearbyDevices = ref.watch(nearbyDevicesProvider);
                  final isConnected = nearbyDevices.hasConnections;
                  final text1 = isConnected
                      ? 'Połączono z ${nearbyDevices.connectedDevicesList.first}!'
                      : 'Trwa wyszukiwanie dostępnych urządzeń';
                  final text2 =
                      isConnected ? 'Oczekiwanie na zatwierdzenie sesji.' : '';
                  return Column(
                    children: [Text(text1), SizedBox(height: 5), Text(text2)],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
