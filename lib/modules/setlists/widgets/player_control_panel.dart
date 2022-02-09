import 'package:flutter/material.dart';

import '../logic/setlist_player/setlist_player_interface.dart';

class PlayerControlPanel extends StatelessWidget {
  final SetlistPlayerInterface player;

  PlayerControlPanel(this.player);

  @override
  Widget build(BuildContext context) {
    final Map<IconData, Function> options = {
      Icons.skip_previous: player.selectPreviousTrack,
      Icons.fast_rewind: player.selectPreviousSection,
      player.isPlaying ? Icons.stop : Icons.play_arrow: () {
        player.isPlaying ? player.stop() : player.play();
      },
      Icons.fast_forward: player.selectNextSection,
      Icons.skip_next: player.selectNextTrack,
    };

    return Container(
      color: Colors.black38,
      height: 74,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: options.entries
            .map(
              (option) => IconButton(
                  icon: Icon(
                    option.key,
                    size: 32,
                  ),
                  onPressed: option.value as void Function()?),
            )
            .toList(),
      ),
    );
  }
}
