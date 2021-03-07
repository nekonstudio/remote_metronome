import 'package:flutter/foundation.dart';
import 'package:metronom/utils/validable/range_validable_property.dart';

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

  @protected
  T getProperty<T>(String name) {
    if (T == RangeValidableProperty) {
      for (final property in validableProperties) {
        if (property is RangeValidableProperty) {
          if (property.name == name) {
            return property as T;
          }
        }
      }
    }

    return null;
  }
}
