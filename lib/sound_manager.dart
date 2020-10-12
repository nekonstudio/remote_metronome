import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

class SoundManager {
  static final SoundManager _singleton = SoundManager._internal();

  int _highClickSoundId;
  int _mediumClickSoundId;
  int _lowClickSoundId;

  int get highClickSoundId {
    return _highClickSoundId;
  }

  int get mediumClickSoundId {
    return _mediumClickSoundId;
  }

  int get lowClickSoundId {
    return _lowClickSoundId;
  }

  final _soundPool = Soundpool(streamType: StreamType.music);

  SoundManager._internal() {
    rootBundle.load('assets/sounds/click_high.ogg').then((data) {
      _soundPool.load(data).then((value) {
        _highClickSoundId = value;
        print('High sound id: $_highClickSoundId');
      });
    });
    rootBundle.load('assets/sounds/click_medium.ogg').then((data) {
      _soundPool.load(data).then((value) {
        _mediumClickSoundId = value;
        print('Medium sound id: $_mediumClickSoundId');
      });
    });
    rootBundle.load('assets/sounds/click_low.ogg').then((data) {
      _soundPool.load(data).then((value) {
        _lowClickSoundId = value;
        print('Low sound id: $_lowClickSoundId');
      });
    });
  }

  factory SoundManager() {
    return _singleton;
  }

  void playSound(int soundId) {
    _soundPool.play(soundId);
  }
}
