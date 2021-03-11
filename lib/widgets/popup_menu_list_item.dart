import 'package:flutter/material.dart';

class PopupMenuListItem extends StatefulWidget {
  final int index;
  final List<PopupMenuEntry<Null Function(int)>> popupMenuEntries;
  final Widget child;
  final void Function() onPressed;

  const PopupMenuListItem({
    Key key,
    @required this.index,
    @required this.popupMenuEntries,
    this.child,
    this.onPressed,
  }) : super(key: key);

  @override
  _PopupMenuListItemState createState() => _PopupMenuListItemState();
}

class _PopupMenuListItemState extends State<PopupMenuListItem> {
  Offset _tapPosition;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: widget.child,
      onTap: widget.onPressed,
      onTapDown: (details) => _tapPosition = details.globalPosition,
      onLongPress: () async {
        final RenderBox overlay = Overlay.of(context).context.findRenderObject();
        final handleSelectedOption = await showMenu(
          context: context,
          items: widget.popupMenuEntries,
          position: RelativeRect.fromRect(
              _tapPosition & const Size(40, 40), // smaller rect, the touch area
              Offset.zero & overlay.size // Bigger rect, the entire screen
              ),
        );

        handleSelectedOption?.call(widget.index);
      },
    );
  }
}
