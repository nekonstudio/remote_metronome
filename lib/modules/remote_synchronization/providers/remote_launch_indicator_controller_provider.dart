import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemoteLaunchIndicatorController with ChangeNotifier {
  static const duration = Duration(milliseconds: 500);

  bool _isActive = false;

  bool get isActive => _isActive;

  void activate() {
    _changeState(true);

    Future.delayed(
      duration + Duration(milliseconds: 120),
      () => _changeState(false),
    );
  }

  void _changeState(bool value) {
    _isActive = value;
    notifyListeners();
  }
}

final remoteLaunchIndicatorControllerProvider = ChangeNotifierProvider(
  (ref) => RemoteLaunchIndicatorController(),
);
