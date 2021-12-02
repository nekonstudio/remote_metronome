import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:metronom/modules/remote_synchronization/providers/nearby_devices_provider.dart';

import '../modules/remote_synchronization/screens/role_choice_screen.dart';
import '../modules/remote_synchronization/widgets/remote_connected_devices_panel.dart';
import '../modules/setlists/screens/saved_setlists_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          SizedBox(
            height: 80,
            child: DrawerHeader(
              child: Text(
                'Metronom',
                style: Theme.of(context).textTheme.headline6,
              ),
              decoration: BoxDecoration(color: Colors.black45),
              padding: const EdgeInsets.only(top: 22, left: 22),
            ),
          ),
          ListTile(
            onTap: () {
              Get.back();
            },
            leading: Icon(Icons.music_note),
            title: Text('Metronom'),
          ),
          ListTile(
            onTap: () {
              Get.to(() => SavedSetlistsScreen());
            },
            title: Text('Setlisty'),
            leading: Icon(Icons.format_list_numbered),
          ),
          Consumer(
            builder: (context, ref, child) {
              final hasConnections =
                  ref.watch(nearbyDevicesProvider).hasConnections;
              final color = hasConnections
                  ? Get.theme.colorScheme.secondary
                  : Colors.white;

              return ListTile(
                onTap: () {
                  if (hasConnections) {
                    Get.back();
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => RemoteConnectedDevicesPanel(),
                    );
                  } else {
                    Get.to(() => RoleChoiceScreen());
                  }
                },
                title: Text(
                  'Wspólne odtwarzanie',
                  style: TextStyle(color: color),
                ),
                leading: Icon(
                  Icons.wifi,
                  color: color,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
