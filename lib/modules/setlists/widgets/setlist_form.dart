import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../logic/setlists_manager.dart';
import '../models/setlist.dart';

class SetlistForm extends StatelessWidget {
  final SetlistManager setlistManager;
  final Setlist? existingSetlist;

  SetlistForm(this.setlistManager, {this.existingSetlist});

  // must be static to prevent keyboard dissapear on TextFormField focus
  // see: https://github.com/flutter/flutter/issues/20042
  static final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    print('SetlistForm buildu buildu');

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
                subtitle: existingSetlist == null
                    ? null
                    : Text(existingSetlist!.name!),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextFormField(
                    initialValue:
                        existingSetlist == null ? '' : existingSetlist!.name,
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
                  ElevatedButton(
                    child: Text(
                      existingSetlist == null ? 'Dodaj' : 'Zmień',
                      style: TextStyle(color: Colors.white),
                    ),
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

  String? _validate(String? value) {
    if (value!.isEmpty) {
      return 'Wprowadź nazwę';
    }

    return null;
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
  }

  void _save(BuildContext context, String? name) {
    if (existingSetlist == null) {
      setlistManager.addSetlist(name);
    } else {
      setlistManager.editSetlist(existingSetlist, name);
    }

    Get.back();
  }
}
