import 'validable.dart';

class RangeValidableProperty implements Validable {
  final String name;
  final dynamic propertyValue;
  final dynamic minValue;
  final dynamic maxValue;

  RangeValidableProperty(
    this.name, {
    required this.propertyValue,
    required this.minValue,
    required this.maxValue,
  });

  @override
  bool isValid() {
    return (propertyValue >= minValue && propertyValue <= maxValue);
  }
}
