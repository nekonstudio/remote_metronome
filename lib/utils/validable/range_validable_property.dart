import 'package:flutter/foundation.dart';
import 'package:metronom/utils/validable/validable.dart';

class RangeValidableProperty implements Validable {
  final dynamic propertyValue;
  final dynamic minValue;
  final dynamic maxValue;

  RangeValidableProperty(
      {@required this.propertyValue,
      @required this.minValue,
      @required this.maxValue});

  @override
  bool isValid() {
    return (propertyValue >= minValue && propertyValue <= maxValue);
  }
}