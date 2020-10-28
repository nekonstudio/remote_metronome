import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:metronom/models/track.dart';
import 'package:metronom/providers/metronome.dart';
import 'package:metronom/providers/setlist_player.dart';
import 'package:metronom/providers/setlists_manager.dart';
import 'package:metronom/widgets/visualization.dart';
import 'package:provider/provider.dart';

class PlayComplexTrackPanel extends StatefulWidget {
  @override
  _PlayComplexTrackPanelState createState() => _PlayComplexTrackPanelState();
}

class _PlayComplexTrackPanelState extends State<PlayComplexTrackPanel> {
  CarouselController _carouselController = CarouselController();
  static const ScrollDuration = 300;

  // void _handleBarCompleted() {
  //   final isSectionFinished = _track.nextBar();
  //   if (isSectionFinished) {
  //     if (!_track.isTrackFinished) {
  //       _currentSection = _track.currentSection;

  //       widget.metronome.change(
  //         tempo: _currentSection.tempo,
  //         beatsPerBar: _currentSection.beatsPerBar,
  //         clicksPerBeat: _currentSection.clicksPerBeat,
  //       );

  //       _carouselController.nextPage(
  //           duration: Duration(milliseconds: _scrollDuration),
  //           curve: Curves.linear);
  //     } else {
  //       _track.reset();
  //       widget.metronome.terminate();
  //       widget.switchTrack();
  //       _carouselController.animateToPage(0,
  //           duration: Duration(milliseconds: _scrollDuration),
  //           curve: Curves.linear);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<SetlistPlayer>(context);
    final currentSection = player.currentSection;
    try {
      _carouselController.animateToPage(player.currentSectionIndex,
          duration: Duration(milliseconds: ScrollDuration),
          curve: Curves.linear);
    } on NoSuchMethodError catch (e) {
      print('Karuzelowy wyjąteczek, ale bezpieczniutki');
    }

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Visualization(currentSection.beatsPerBar),
        ),
        Expanded(
          flex: 3,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              '${currentSection.tempo}',
              style: TextStyle(fontSize: 60),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: CarouselSlider(
              items: player.currentTrack.sections
                  .asMap()
                  .entries
                  .map((sectionEntry) {
                final isCurrent =
                    sectionEntry.key == player.currentSectionIndex;
                final section = sectionEntry.value;
                return AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: ScrollDuration),
                  style: TextStyle(
                    color: isCurrent ? Colors.white : Colors.white70,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    fontSize: isCurrent ? 14 : 12,
                  ),
                  child: Padding(
                    padding:
                        isCurrent ? EdgeInsets.zero : EdgeInsets.only(top: 2),
                    child: Text(
                      isCurrent
                          ? '${section.title} ${player.currentSectionBar}/${section.barsCount}'
                          : '${section.title}',
                    ),
                  ),
                );
              }).toList(),
              carouselController: _carouselController,
              options: CarouselOptions(
                // height: 10,
                aspectRatio: 20,
                enableInfiniteScroll: false,
                viewportFraction: 0.33,
                // enlargeCenterPage: true,
                scrollPhysics: NeverScrollableScrollPhysics(),
              )),
        )
      ],
    );
  }
}
