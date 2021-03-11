import 'package:flutter/material.dart';

import 'circle_button.dart';

class TextCircleButton extends StatelessWidget {
  final String text;
  final double size;
  final void Function() onPressed;

  const TextCircleButton(
    this.text, {
    Key key,
    this.onPressed,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleButton(
      child: Text(text,
          style: TextStyle(
            color: Colors.white,
          )),
      size: size,
      color: Colors.black,
      onPressed: onPressed,
    );
  }
}
