import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final Widget child;
  final double size;
  final Color color;
  final void Function() onPressed;

  const CircleButton({
    Key key,
    this.child,
    this.size,
    this.color,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CircleAvatar(
        radius: size,
        child: child,
        backgroundColor: color,
      ),
      onTap: onPressed,
    );
  }
}
