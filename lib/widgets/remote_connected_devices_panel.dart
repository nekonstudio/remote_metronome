import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metronom/providers/nearby/nearby_devices.dart';
import 'package:metronom/providers/remote/remote_synchronization.dart';

import 'connected_nearby_devices_list.dart';

class RemoteConnectedDevicesPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.connect_without_contact,
            color: Get.theme.accentColor,
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
                  context.read(nearbyDevicesProvider).finish();
                  context.read(synchronizationProvider).end();
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
