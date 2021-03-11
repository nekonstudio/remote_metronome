import 'package:flutter/material.dart';

class TapTempoDetectorButton extends StatelessWidget {
  final bool isTempoDetectionActive;
  final bool isDisabled;
  final void Function() onPressed;

  const TapTempoDetectorButton({
    Key key,
    @required this.isTempoDetectionActive,
    @required this.isDisabled,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: isTempoDetectionActive ? Colors.white : Colors.blueGrey,
      child: Material(
        shape: CircleBorder(),
        color: Colors.blueGrey,
        clipBehavior: Clip.hardEdge,
        child: GestureDetector(
          onTapDown: (_) => onPressed(),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 28,
            child: Icon(
              Icons.touch_app,
              color: isDisabled ? Colors.grey : Colors.white,
              size: 35,
            ),
          ),
        ),
      ),
    );
  }
}
