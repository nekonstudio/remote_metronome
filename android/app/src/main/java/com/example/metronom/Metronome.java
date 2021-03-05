package com.example.metronom;


import android.os.Handler;
import android.os.Looper;

import io.flutter.plugin.common.EventChannel;

class Metronome {
    private static final String TAG = "Metronome";

    private MetronomeSoundPlayer _soundPlayer;
    private EventChannel.EventSink _barBeatEventStream;

    private boolean _isPlaying;

    private MetronomeSettings _settings;

    private int _previousClicksPerBeat;
    private boolean _isSynchronizedMetronome;
    private boolean _playSynchronizedMetronome;
    private Integer _currentBeatPerBar = 1;
    private int _currentClickPerBeat = 1;

    Metronome(MetronomeSoundPlayer soundPlayer, EventChannel barBeatChannel) {
        _soundPlayer = soundPlayer;

        barBeatChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                _barBeatEventStream = events;
            }

            @Override
            public void onCancel(Object arguments) {
                _barBeatEventStream.endOfStream();
                _barBeatEventStream = null;
            }
        });
    }

    void start(MetronomeSettings metronomeSettings) {
        _isPlaying = true;
        _settings = metronomeSettings;
        _previousClicksPerBeat = metronomeSettings.clicksPerBeat;

        _soundPlayer.configure(metronomeSettings);
        _soundPlayer.start();

        new MetronomePlayerThread().start();
    }

    void prepareSynchronizedStart(MetronomeSettings metronomeSettings) {
        _isSynchronizedMetronome = true;
        _playSynchronizedMetronome = false;

        start(metronomeSettings);
    }

    void synchronizedStart() {
        _playSynchronizedMetronome = true;
    }

    void change(MetronomeSettings metronomeSettings) {
        _previousClicksPerBeat = _settings.clicksPerBeat;
        _settings = metronomeSettings;

        _soundPlayer.configure(metronomeSettings);
    }

    void stop() {
        _isPlaying = false;

        _soundPlayer.stop();

        _currentBeatPerBar = 1;
        _currentClickPerBeat = 1;
        _previousClicksPerBeat = 1;

        _isSynchronizedMetronome = false;
        _playSynchronizedMetronome = false;

        _barBeatEventStream.success(0);
    }

    class MetronomePlayerThread extends Thread {
        @Override
        public void run() {
            Thread.currentThread().setPriority(Thread.MAX_PRIORITY);
            Handler handler = new Handler(Looper.getMainLooper());

            while(_isPlaying)
            {
                streamCurrentBeatsPerBar(handler);
                _soundPlayer.generateCurrentSound(_currentBeatPerBar, _currentClickPerBeat);

                if (_isSynchronizedMetronome) {
                    while (!_playSynchronizedMetronome) {
                        android.os.SystemClock.sleep(1);
                    }
                }

                _soundPlayer.playCurrentSound();
                handleMetronomeControlData();
            }
        }


        private void streamCurrentBeatsPerBar(Handler handler) {
            handler.post(() -> {
                if (_barBeatEventStream != null) {
                    final int copy = _currentBeatPerBar;
                    _barBeatEventStream.success(copy);
                }
            });
        }

        private void handleMetronomeControlData() {
            _currentClickPerBeat++;

            // switch to next beat when clicksPerBeat setting changed to higher value while playing
            if (_previousClicksPerBeat < _settings.clicksPerBeat) {
                nextBeatPerBar();

                _previousClicksPerBeat = _settings.clicksPerBeat;
            }
            else if (_currentClickPerBeat > _settings.clicksPerBeat) {
                nextBeatPerBar();
            }
        }

        private void nextBeatPerBar() {
            _currentClickPerBeat = 1;
            _currentBeatPerBar++;
            if (_currentBeatPerBar > _settings.beatsPerBar) {
                _currentBeatPerBar = 1;
            }
        }
    }
}
