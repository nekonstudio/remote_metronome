import 'package:flutter/cupertino.dart';

class Track with ChangeNotifier {
  String id = DateTime.now().toString();
  String name;
  int tempo;
  int beatsPerBar;
  int clicksPerBeat;
  bool isComplex;
  List<Section> sections;

  Track.simple(this.name, this.tempo, this.beatsPerBar, this.clicksPerBeat)
      : isComplex = false;

  Track.complex(this.name, this.sections) : isComplex = true;

  Track(
      {this.name,
      this.tempo,
      this.beatsPerBar,
      this.clicksPerBeat,
      this.isComplex,
      this.sections});

  int _currentSectionIndex = 0;
  bool _isFinished = false;

  int get currentSectionIndex {
    return _currentSectionIndex;
  }

  bool get isTrackFinished {
    return _isFinished;
  }

  Section get currentSection {
    // print('_currentSectionIndex: $_currentSectionIndex');
    return sections[_currentSectionIndex];
  }

  int get currentSectionBar {
    return currentSection.currentBar;
  }

  bool nextBar() {
    final isFinished = currentSection.nextBar();
    if (isFinished) {
      selectNextSection();

      return true;
    }

    notifyListeners();

    return false;
  }

  void selectNextSection() {
    if (isComplex) {
      if (_currentSectionIndex >= sections.length - 1) {
        _isFinished = true;
        return;
      }

      currentSection.reset();
      _currentSectionIndex++;

      notifyListeners();
    }
  }

  void selectPreviousSection() {
    if (isComplex && _currentSectionIndex > 0) {
      currentSection.reset();
      _currentSectionIndex--;

      notifyListeners();
    }
  }

  void reset() {
    _currentSectionIndex = 0;
    _isFinished = false;

    notifyListeners();
  }
}

class Section {
  String title;
  int tempo;
  int barsCount;
  int beatsPerBar;
  int clicksPerBeat;

  Section({
    this.title,
    this.tempo,
    this.barsCount,
    this.beatsPerBar,
    this.clicksPerBeat,
  });

  int _currentBar = 1;

  bool nextBar() {
    bool isFinished = false;
    if (_currentBar >= barsCount) {
      isFinished = true;
      reset();
    } else {
      _currentBar++;
    }

    return isFinished;
  }

  int get currentBar {
    return _currentBar;
  }

  void reset() {
    _currentBar = 1;
  }
}
