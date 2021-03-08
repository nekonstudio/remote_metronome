import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../metronome/providers/metronome_provider.dart';
import '../../remote_synchronization/providers/device_synchronization_mode_notifier_provider.dart';
import '../../remote_synchronization/providers/remote_synchronization_provider.dart';
import '../logic/setlist_player/notifier_setlist_player.dart';
import '../logic/setlist_player/remote_synchronized_setlist_player.dart';
import '../logic/setlist_player/setlist_player.dart';
import '../models/setlist.dart';

SetlistPlayer _setlistPlayerCopy;

final setlistPlayerProvider =
    ChangeNotifierProvider.autoDispose.family<NotifierSetlistPlayer, Setlist>(
  (ref, setlist) {
    final modeProvider = ref.watch(deviceSynchronizationModeNotifierProvider);
    final metronome = ref.watch(metronomeImplProvider);

    final impl = modeProvider.isSynchronized
        ? RemoteSynchronizedSetlistPlayer(ref.read(synchronizationProvider), setlist, metronome)
        : SetlistPlayer(setlist, metronome);

    if (_setlistPlayerCopy != null) {
      if (modeProvider.previousMode == DeviceSynchronizationMode.Host) {
        modeProvider.resetPreviousMode();
        impl.copy(_setlistPlayerCopy);
      }
    }

    _setlistPlayerCopy = impl;

    return NotifierSetlistPlayer(impl);
  },
);
