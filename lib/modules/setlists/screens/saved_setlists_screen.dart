import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../widgets/popup_menu_list_item.dart';
import '../../metronome/providers/metronome_provider.dart';
import '../../remote_synchronization/widgets/remote_mode_screen.dart';
import '../logic/setlists_manager.dart';
import '../models/setlist.dart';
import '../providers/setlist_manager_provider.dart';
import '../widgets/setlist_form.dart';
import 'setlist_screen.dart';

class SavedSetlistsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setlistManager = ref.watch(setlistManagerProvider);
    final setlists = setlistManager.setlists;

    ref.read(metronomeProvider).stop();

    return RemoteModeScreen(
      title: Text('Setlisty'),
      body: setlists.length == 0
          ? Center(
              child: Text('Brak setlist'),
            )
          : ListView.separated(
              separatorBuilder: (context, index) => Divider(),
              itemCount: setlists.length,
              itemBuilder: (context, index) {
                final setlist = setlists[index]!;
                return PopupMenuListItem(
                  index: index,
                  popupMenuEntries:
                      _buildPopupMenuItems(context, setlistManager, setlist),
                  onPressed: () => Get.to(() => SetlistScreen(setlist)),
                  child: ListTile(
                    leading: Icon(Icons.menu),
                    title: Text('${setlist.name}'),
                    subtitle: Text('Liczba utworów: ${setlist.tracksCount}'),
                    trailing: Text(''),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) => SetlistForm(setlistManager),
          );
        },
      ),
    );
  }

  dynamic _buildPopupMenuItems(
      BuildContext context, SetlistManager setlistManager, Setlist setlist) {
    return [
      PopupMenuItem(
        child: Text('Edytuj'),
        value: (index) {
          print('hejka');
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) =>
                SetlistForm(setlistManager, existingSetlist: setlist),
          );
        },
      ),
      PopupMenuItem(
          child: Text('Usuń'),
          value: (index) {
            setlistManager.deleteSetlist(index);
          }),
    ];
  }
}
