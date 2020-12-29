import 'package:flutter/foundation.dart';

import 'validable.dart';

abstract class PropertyValidable implements Validable {
  @override
  bool isValid() {
    for (final property in validableProperties) {
      if (!property.isValid()) return false;
    }

    return true;
  }

  @protected
  List<Validable> get validableProperties;
}
