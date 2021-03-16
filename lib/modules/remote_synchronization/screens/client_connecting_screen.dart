import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../providers/device_synchronization_mode_notifier_provider.dart';
import '../providers/nearby_devices_provider.dart';
import 'remote_metronome_client_screen.dart';

class ClientConnectingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.read(nearbyDevicesProvider).discover();
    return ProviderListener<DeviceSynchronizationModeNotifier>(
      provider: deviceSynchronizationModeNotifierProvider,
      onChange: (context, deviceSynchronizationModeNotifier) {
        if (deviceSynchronizationModeNotifier.mode == DeviceSynchronizationMode.Client) {
          final hostName = context.read(nearbyDevicesProvider).connectedDevicesList.first;
          Get.off(RemoteMetronomeClientScreen(hostName));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Wspólne odtwarzanie'),
        ),
        body: WillPopScope(
          onWillPop: () async {
            context.read(nearbyDevicesProvider).finish();
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
                  builder: (context, watch, child) {
                    final nearbyDevices = watch(nearbyDevicesProvider);
                    final isConnected = nearbyDevices.hasConnections;
                    final text1 = isConnected
                        ? 'Połączono z ${nearbyDevices.connectedDevicesList.first}!'
                        : 'Trwa wyszukiwanie dostępnych urządzeń';
                    final text2 = isConnected ? 'Oczekiwanie na zatwierdzenie sesji.' : '';
                    return Column(
                      children: [Text(text1), SizedBox(height: 5), Text(text2)],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
