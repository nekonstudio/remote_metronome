package com.example.metronom;

import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.metronom/metronom";
    private static final String TAG = "MetronomePlugin";

    private Metronome _metronome;
//    private SoundPlayer testSoundPlayer = new SoundPlayer();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

//        testSoundPlayer.start();
    }

    @Override
    protected void onDestroy() {
//        testSoundPlayer.stop();

        super.onDestroy();
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        initializeMetronome(flutterEngine);
        handleMethodCall(flutterEngine);
    }

    private void initializeMetronome(@NonNull FlutterEngine flutterEngine) {
        final EventChannel barBeatChannel = new EventChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                "com.example.metronom/barBeatChannel");
        final MetronomeSoundPlayer metronomeSoundPlayer = new MetronomeSoundPlayer();
//        metronomeSoundPlayer.loadSoundsFromAssets(getAssets());
        metronomeSoundPlayer.setupAudioSources(getAssets());

        _metronome = new Metronome(metronomeSoundPlayer, barBeatChannel);
//        final byte[] buffer = metronomeSoundPlayer._soundBuffers.get(MetronomeSoundPlayer.SoundId.HIGH_SOUND);
//        _metronome.setSoundBuffer(buffer, buffer.length);
    }

    private void handleMethodCall(@NonNull FlutterEngine flutterEngine) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    boolean isSuccess = true;

                    switch (call.method) {
                        case "start":
//                            testSoundPlayer.start();
                            _metronome.start(MetronomeSettings.fromMethodCall(call));
                            break;

                        case "prepareSynchronizedStart":
                            _metronome.prepareSynchronizedStart(MetronomeSettings.fromMethodCall(call));
                            break;

                        case "synchronizedStart":
                            _metronome.synchronizedStart();
                            break;

                        case "stop":
//                            testSoundPlayer.stop();
                            _metronome.stop();
                            break;

                        case "change":
                            _metronome.change(MetronomeSettings.fromMethodCall(call));
                            break;

                        default:
                            Log.d(TAG, "method name: " + call.method);
                            isSuccess = false;
                            break;
                    }

                     if (isSuccess) {
                         result.success(null);
                     } else {
                         result.notImplemented();
                     }
                }
            );
    }
}