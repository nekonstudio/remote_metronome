import 'package:flutter/material.dart';

mixin ListItemLongPressPopupMenu {
  var _tapPosition;

  void storeTapPosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  void showPopupMenu(
    BuildContext context,
    int index,
    List<PopupMenuEntry<Null Function(int)>> items,
  ) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();

    showMenu(
      context: context,
      items: items,
      position: RelativeRect.fromRect(
          _tapPosition & const Size(40, 40), // smaller rect, the touch area
          Offset.zero & overlay.size // Bigger rect, the entire screen
          ),
    ).then((handler) {
      if (handler != null) {
        handler(index);
      }
    });
  }
}
