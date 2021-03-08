import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'remote_synchronization_provider.dart';

class RemoteActionNotifier extends StateNotifier<bool> {
  RemoteActionNotifier(bool state) : super(state);

  void setActionState(bool value) => state = value;
}

final remoteActionNotifierProvider = StateNotifierProvider<RemoteActionNotifier>(
  (ref) => ref.read(synchronizationProvider).remoteActionNotifier,
);
