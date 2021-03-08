import 'package:flutter_riverpod/flutter_riverpod.dart';

class IsRemoteSetlistScreenNotifier extends StateNotifier<bool> {
  IsRemoteSetlistScreenNotifier(bool state) : super(state);

  void changeState(bool value) {
    if (value != state) state = value;
  }
}

final isRemoteSetlistScreenProvider = StateNotifierProvider(
  (ref) => IsRemoteSetlistScreenNotifier(false),
);
