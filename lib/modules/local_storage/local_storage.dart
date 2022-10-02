import 'dart:convert';

import 'package:hive/hive.dart';

import '../../modules/metronome/models/metronome_settings.dart';
import '../../modules/setlists/models/setlist.dart';

class LocalStorage {
  static const String BoxName = 'savedData';

  MetronomeSettings getMetronomeSettings() => _data.get(
        'metronomeSettings',
        defaultValue: MetronomeSettings(),
      );

  void saveMetronomeSettings(MetronomeSettings value) =>
      _data.put('metronomeSettings', value);

  List<Setlist> getSetlists() {
    final jsonValue = _data.get('setlists') as String?;

    final setlistMap = jsonValue != null ? json.decode(jsonValue) : null;
    final List<Setlist> setlists = jsonValue != null
        ? List<Setlist>.from(setlistMap?.map((x) => Setlist.fromMap(x)))
        : <Setlist>[];

    return setlists;
  }

  Future<void> saveSetlists(List<Setlist?> value) {
    final jsonValue = json.encode(value.map((x) => x?.toMap()).toList());
    return _data.put('setlists', jsonValue);
  }

  bool isFirstAppLaunch() {
    final value = _data.get('isFirstAppLaunch') as bool? ?? true;
    if (value == true) {
      _data.put('isFirstAppLaunch', false);
    }

    return value;
  }

  Box<dynamic> get _data => Hive.box(BoxName);
}
