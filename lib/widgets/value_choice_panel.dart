import 'package:flutter/material.dart';

import 'text_circle_button.dart';

class ValueChoicePanel extends StatelessWidget {
  final int value;
  final String title;
  final void Function() onValueDecrement;
  final void Function() onValueIncrement;

  const ValueChoicePanel({
    @required this.value,
    Key key,
    this.title,
    this.onValueDecrement,
    this.onValueIncrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12),
        ),
        SizedBox(
          height: 6,
        ),
        SizedBox(
          width: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextCircleButton(
                '-',
                size: 13,
                onPressed: onValueDecrement,
              ),
              Text(
                '$value',
                style: TextStyle(fontSize: 26),
              ),
              TextCircleButton(
                '+',
                size: 13,
                onPressed: onValueIncrement,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
