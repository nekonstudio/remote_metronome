import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../mixins/list_item_long_press_popup_menu.dart';
import '../../models/setlist.dart';
import '../../providers/setlists_manager.dart';
import '../../widgets/remote_mode_screen.dart';
import 'setlist_screen.dart';

class SavedSetlistsScreen extends ConsumerWidget
    with ListItemLongPressPopupMenu {
  static const String routePath = '/savedSetlists';

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final setlistManager = watch(setlistManagerProvider);
    final setlists = setlistManager.setlists;

    return RemoteModeScreen(
      title: Text('Setlisty'),
      body: Container(
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: setlists.length,
          itemBuilder: (context, index) {
            final setlist = setlists[index];
            return InkWell(
              onTap: () {
                Get.to(SetlistScreen(), arguments: setlist.id);
              },
              onTapDown: (details) => storeTapPosition(details),
              onLongPress: () => showPopupMenu(context, index,
                  _buildPopupMenuItems(context, setlistManager, setlist)),
              child: ListTile(
                leading: Icon(Icons.menu),
                title: Text('${setlist.name}'),
                subtitle: Text('Liczba utworów: ${setlist.tracksCount}'),
                trailing: Text(''),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) => _AddSetlistPanel(setlistManager),
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
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) =>
                _AddSetlistPanel(setlistManager, existingSetlist: setlist),
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

class _AddSetlistPanel extends StatelessWidget {
  final SetlistManager setlistManager;
  final Setlist existingSetlist;
  _AddSetlistPanel(this.setlistManager, {this.existingSetlist});

  static final _formKey = GlobalKey<FormState>();

  String _validate(String value) {
    if (value.isEmpty) {
      return 'Wprowadź nazwę';
    }

    return null;
  }

  void _onSubmit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
    }
  }

  void _save(BuildContext context, String name) {
    if (existingSetlist == null) {
      setlistManager.addSetlist(name);
    } else {
      setlistManager.editSetlist(existingSetlist, name);
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        height: MediaQuery.of(context).viewInsets.bottom + 230,
        child: Column(
          children: [
            Container(
              color: Colors.black26,
              child: ListTile(
                leading: Icon(existingSetlist == null
                    ? Icons.playlist_add
                    : Icons.playlist_add_check),
                title: Text(existingSetlist == null
                    ? 'Nowa setlista'
                    : 'Edytuj setlistę'),
                subtitle:
                    existingSetlist == null ? null : Text(existingSetlist.name),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextFormField(
                    initialValue:
                        existingSetlist == null ? '' : existingSetlist.name,
                    decoration: InputDecoration(labelText: 'Nazwa'),
                    autofocus: true,
                    validator: _validate,
                    onFieldSubmitted: (_) {
                      _onSubmit();
                    },
                    onSaved: (value) {
                      _save(context, value);
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  RaisedButton(
                    child: Text(existingSetlist == null ? 'Dodaj' : 'Zmień'),
                    onPressed: _onSubmit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
