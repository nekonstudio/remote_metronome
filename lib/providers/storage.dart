import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:metronom/models/setlist.dart';
import 'package:metronom/providers/metronome/metronome_settings.dart';

class Storage {
  static const String BoxName = 'savedData';

  Storage() {
    // _data.delete('metronomeSettings');
    // _data.delete('setlists');
  }

  Box<dynamic> get _data => Hive.box(BoxName);

  MetronomeSettings getMetronomeSettings() => _data.get(
        'metronomeSettings',
        defaultValue: MetronomeSettings(),
      );

  void saveMetronomeSettings(MetronomeSettings value) => _data.put('metronomeSettings', value);

  List<Setlist> getSetlists() {
    final jsonValue = _data.get(
      'setlists',
    ) as String;

    final setlistMap = jsonValue != null ? json.decode(jsonValue) : null;
    final setlists = jsonValue != null
        ? List<Setlist>.from(setlistMap?.map((x) => Setlist.fromMap(x)))
        : List<Setlist>();

    return setlists;
  }

  Future<void> saveSetlists(List<Setlist> value) {
    final jsonValue = json.encode(value?.map((x) => x?.toMap())?.toList());
    return _data.put('setlists', jsonValue);
  }
}

final storageProvider = Provider((ref) => Storage());
