import 'dart:ffi';

typedef VoidCallbackC = Void Function();
typedef VoidCallback = void Function();

class NativeAndroidMetronomeBridge {
  late VoidCallback _start;
  late VoidCallback _stop;

  NativeAndroidMetronomeBridge() {
    final lib = DynamicLibrary.open('libnative-android-metronome.so');
    _start = lib.lookupFunction<VoidCallbackC, VoidCallback>('start');
    _stop = lib.lookupFunction<VoidCallbackC, VoidCallback>('stop');
  }

  void start() => _start();
  void stop() => _stop();
}
