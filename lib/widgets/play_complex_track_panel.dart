import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/setlist_player.dart';
import 'visualization.dart';

class PlayComplexTrackPanel extends StatefulWidget {
  @override
  _PlayComplexTrackPanelState createState() => _PlayComplexTrackPanelState();
}

class _PlayComplexTrackPanelState extends State<PlayComplexTrackPanel> {
  CarouselController _carouselController = CarouselController();
  static const ScrollDuration = 300;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final player = watch(setlistPlayerProvider);
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
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                        fontSize: isCurrent ? 14 : 12,
                      ),
                      child: Padding(
                        padding: isCurrent
                            ? EdgeInsets.zero
                            : EdgeInsets.only(top: 2),
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
      },
    );
  }
}
