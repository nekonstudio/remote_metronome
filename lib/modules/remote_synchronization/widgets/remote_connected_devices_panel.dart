import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../providers/nearby_devices_provider.dart';
import '../providers/remote_synchronization_provider.dart';
import 'connected_nearby_devices_list.dart';

class RemoteConnectedDevicesPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.connect_without_contact,
            color: Get.theme.colorScheme.secondary,
          ),
          title: Text('Wspólne odtwarzanie'),
          subtitle: Text('Połączone urządzenia'),
          tileColor: Get.theme.primaryColor,
        ),
        Expanded(
          child: ConnectedNearbyDevicesList(),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                child: Text('Powrót'),
                onPressed: () {
                  Get.back();
                },
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                child: Text('Zakończ'),
                onPressed: () {
                  ref.read(nearbyDevicesProvider).finish();
                  ref.read(synchronizationProvider).end();
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
