import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'connected_nearby_devices_list.dart';

class RemoteConnectedDevicesPanel extends StatelessWidget {
  final bool isModalVersion;

  const RemoteConnectedDevicesPanel({
    Key key,
    this.isModalVersion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // if (isModalVersion) ListTile(),
        // Container(),
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
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
