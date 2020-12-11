import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../providers/nearby/nearby_devices.dart';
import '../screens/playing_together_intro_screen.dart';
import '../screens/saved_setlists_screen.dart';

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
              Get.to(SavedSetlistsScreen());
            },
            title: Text('Setlisty'),
            leading: Icon(Icons.format_list_numbered),
          ),
          Consumer(
            builder: (context, watch, child) {
              final hasConnections =
                  watch(nearbyDevicesProvider).hasConnections;
              final color =
                  hasConnections ? Get.theme.accentColor : Colors.white;

              return ListTile(
                onTap: () {
                  Get.to(PlayingTogetherIntroScreen());
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
          // ListTile(
          //   onTap: () {
          //     Get.to(NearbyHost());
          //   },
          //   title: Text('Nearby host'),
          //   leading: Icon(Icons.connect_without_contact),
          // ),
          // ListTile(
          //   onTap: () {
          //     Get.to(NearbyClient());
          //   },
          //   title: Text('Nearby client'),
          //   leading: Icon(Icons.connect_without_contact),
          // ),
        ],
      ),
    );
  }
}
