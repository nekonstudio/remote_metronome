import 'package:flutter/material.dart';

import 'circle_button.dart';

class IconCircleButton extends StatelessWidget {
  final IconData? icon;
  final Color? color;
  final void Function()? onPressed;

  const IconCircleButton({
    Key? key,
    this.icon,
    this.color,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleButton(
      child: Icon(
        icon,
        color: Colors.white,
        size: 45,
      ),
      size: 38,
      color: color,
      onPressed: onPressed,
    );
  }
}
