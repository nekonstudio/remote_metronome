import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metronom/screens/playing_together_host_screen.dart';
import 'package:metronom/screens/playing_together_intro_screen.dart';

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
          ListTile(
            onTap: () {
              // Get.to(BluetoothScreen());
              Get.to(PlayingTogetherIntroScreen());
            },
            title: Text('Wspólne odtwarzanie'),
            leading: Icon(Icons.bluetooth_audio),
          ),
        ],
      ),
    );
  }
}
