import 'dart:async';
import 'dart:ffi';

import 'dart:isolate';

typedef VoidCallback = void Function();
typedef VoidCallbackC = Void Function();

typedef StartFunc = void Function(int, int, int);
typedef StartFuncC = Void Function(Int32, Int32, Int32);

typedef StopFunc = void Function(bool);
typedef StopFuncC = Void Function(Bool);

typedef PrepareSyncStartFunc = void Function(int, int, int);
typedef PrepareSyncStartFuncC = Void Function(Int32, Int32, Int32);

typedef ChangeFunc = void Function(int, int, bool);
typedef ChangeFuncC = Void Function(Int32, Int32, Bool);

typedef CurrentBarBeatCallback = Void Function(Int32);

typedef SetCallbackFunc = void Function(
    Pointer<NativeFunction<CurrentBarBeatCallback>>);

typedef SetCallbackFuncC = Void Function(
    Pointer<NativeFunction<CurrentBarBeatCallback>>);

class NativeAndroidMetronomeBridge {
  late StartFunc _start;
  late StopFunc _stop;
  late ChangeFunc _change;
  late PrepareSyncStartFunc _prepareSyncStart;
  late VoidCallback _runSyncStart;

  late Stream<dynamic> _currentBarBeatStream;

  NativeAndroidMetronomeBridge() {
    final lib = DynamicLibrary.open('libnative-android-metronome.so');
    _start = lib.lookupFunction<StartFuncC, StartFunc>('start');
    _stop = lib.lookupFunction<StopFuncC, StopFunc>('stop');
    _change = lib.lookupFunction<ChangeFuncC, ChangeFunc>('change');
    _prepareSyncStart =
        lib.lookupFunction<PrepareSyncStartFuncC, PrepareSyncStartFunc>(
            'prepareSynchronizedStart');
    _runSyncStart =
        lib.lookupFunction<VoidCallbackC, VoidCallback>('runSynchronizedStart');

    initNativeMessenging(lib);
  }

  void initNativeMessenging(DynamicLibrary lib) async {
    final initializeApi = lib.lookupFunction<IntPtr Function(Pointer<Void>),
        int Function(Pointer<Void>)>("InitializeDartApi");
    final result = initializeApi(NativeApi.initializeApiDLData);
    if (result != 0) {
      throw "Failed to initialize Dart API";
    }

    final interactiveCppRequests = ReceivePort();
    _currentBarBeatStream = interactiveCppRequests.asBroadcastStream();

    final int nativePort = interactiveCppRequests.sendPort.nativePort;

    final void Function(int port) setDartApiMessagePort = lib
        .lookup<NativeFunction<Void Function(Int64 port)>>(
            "SetDartApiMessagePort")
        .asFunction();
    setDartApiMessagePort(nativePort);
  }

  void start(int tempo, int clicksPerBeat, int beatsPerBar) =>
      _start(tempo, clicksPerBeat, beatsPerBar);

  void stop({bool immediate = true}) => _stop(immediate);

  void change(int tempo, int clicksPerBeat, bool immediate) =>
      _change(tempo, clicksPerBeat, immediate);

  void prepareSynchronizedStart(
          int tempo, int clicksPerBeat, int beatsPerBar) =>
      _prepareSyncStart(tempo, clicksPerBeat, beatsPerBar);

  void runSynchronizedStart() => _runSyncStart();

  Stream<dynamic> currentBarBeatStream() => _currentBarBeatStream;
}
