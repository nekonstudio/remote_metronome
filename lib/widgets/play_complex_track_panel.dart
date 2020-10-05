import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:metronom/models/track.dart';
import 'package:metronom/providers/metronome.dart';
import 'package:metronom/providers/setlists_manager.dart';
import 'package:metronom/widgets/visualization.dart';
import 'package:provider/provider.dart';

class PlayComplexTrackPanel extends StatefulWidget {
  final Metronome metronome;
  final Function switchTrack;

  PlayComplexTrackPanel(this.metronome, this.switchTrack);

  @override
  _PlayComplexTrackPanelState createState() => _PlayComplexTrackPanelState();
}

class _PlayComplexTrackPanelState extends State<PlayComplexTrackPanel> {
  // int _currentSectionBar = 1;

  Track _track;
  List<Section> _sections;
  Section _currentSection;

  CarouselController _carouselController = CarouselController();
  final int _scrollDuration = 300;

  @override
  void dispose() {
    _track.reset();
    super.dispose();
  }

  void _handleBarCompleted() {
    final isSectionFinished = _track.nextBar();
    if (isSectionFinished) {
      if (!_track.isTrackFinished) {
        _currentSection = _track.currentSection;

        widget.metronome.change(
            _currentSection.tempo, widget.metronome.isPlaying,
            beatsPerBar: _currentSection.beatsPerBar,
            clicksPerBeat: _currentSection.clicksPerBeat);

        _carouselController.nextPage(
            duration: Duration(milliseconds: _scrollDuration),
            curve: Curves.linear);
      } else {
        _track.reset();
        widget.metronome.terminate();
        widget.switchTrack();
        _carouselController.animateToPage(0,
            duration: Duration(milliseconds: _scrollDuration),
            curve: Curves.linear);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _track = Provider.of<Track>(context);
    _sections = _track.sections;
    _currentSection = _track.currentSection;
    try {
      _carouselController.animateToPage(_track.currentSectionIndex,
          duration: Duration(milliseconds: _scrollDuration),
          curve: Curves.linear);
    } on NoSuchMethodError catch (e) {
      print('Karuzelowy wyjąteczek, ale bezpieczniutki');
    }
    widget.metronome.setBarCompletedCallback(_handleBarCompleted);

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Visualization(
              _currentSection.beatsPerBar, widget.metronome.currentBarBeat),
        ),
        Expanded(
          flex: 3,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              '${_currentSection.tempo}',
              style: TextStyle(fontSize: 60),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: CarouselSlider(
              items: _sections.asMap().entries.map((sectionEntry) {
                final isCurrent =
                    sectionEntry.key == _track.currentSectionIndex;
                final section = sectionEntry.value;
                return AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: _scrollDuration),
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
                          ? '${section.title} ${_track.currentSectionBar}/${section.barsCount}'
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

class _LabelCircularBuffer {
  final List<String> _values;
  final int size;
  int _start = 0;
  int _end = 0;
  int _count = 0;

  _LabelCircularBuffer(this.size)
      : _values = List.generate(size, (index) => '');

  void insert(String value) {
    _end++;
    if (_end == _values.length) {
      _end = 0;
    }
    _values[_end] = value;

    // print('Insert: $_values');

    _count++;
    if (_count < _values.length) {
      // print('Count: $_count');
      return;
    }

    _start++;
    if (_start == _values.length) {
      _start = 0;
    }
  }

  String operator [](int index) {
    if (index >= size) {
      throw 'Index $index is out of the boundaries ($index >= $size)';
    }

    int _index = _start + index;
    if (_index >= size) {
      _index = _start + index - size;
    }

    // print('get start: $_start');
    // print('get index: $_index');
    // print('get: ${_values[_index]}');

    return _values[_index];
  }
}
