import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:metronom/models/section.dart';
import 'package:metronom/providers/setlist_player/setlist_player.dart';

class AnimatedTrackSections extends StatefulWidget {
  static const ScrollDuration = 300;

  final SetlistPlayer player;
  final List<Section> sections;

  AnimatedTrackSections(this.player, this.sections);

  @override
  _AnimatedTrackSectionsState createState() => _AnimatedTrackSectionsState();
}

class _AnimatedTrackSectionsState extends State<AnimatedTrackSections> {
  final CarouselController carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    final animateToCurrentSection = () => carouselController.animateToPage(
        widget.player.currentSectionIndex,
        duration: Duration(milliseconds: AnimatedTrackSections.ScrollDuration),
        curve: Curves.linear);

    if (carouselController.ready) {
      animateToCurrentSection();
    } else {
      carouselController.onReady.then((value) => animateToCurrentSection());
    }

    return CarouselSlider(
      items: widget.sections.asMap().entries.map((sectionEntry) {
        final isCurrent = sectionEntry.key == widget.player.currentSectionIndex;
        final section = sectionEntry.value;
        return AnimatedDefaultTextStyle(
          duration:
              Duration(milliseconds: AnimatedTrackSections.ScrollDuration),
          style: TextStyle(
            color: isCurrent ? Colors.white : Colors.white70,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            fontSize: isCurrent ? 14 : 12,
          ),
          child: Padding(
            padding: isCurrent ? EdgeInsets.zero : EdgeInsets.only(top: 2),
            child: Text(
              isCurrent
                  ? '${section.title} ${widget.player.currentSectionBar}/${section.barsCount}'
                  : '${section.title}',
            ),
          ),
        );
      }).toList(),
      carouselController: carouselController,
      options: CarouselOptions(
        aspectRatio: 20,
        enableInfiniteScroll: false,
        viewportFraction: 0.33,
        scrollPhysics: NeverScrollableScrollPhysics(),
      ),
    );
  }
}
