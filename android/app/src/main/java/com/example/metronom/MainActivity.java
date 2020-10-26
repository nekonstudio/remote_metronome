package com.example.metronom;

import android.content.Context;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.PersistableBundle;
import android.os.PowerManager;
import android.util.Log;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Random;
import java.util.Timer;
import java.util.TimerTask;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.metronom/metronom";
    private static final String TAG = "MetronomePlugin";

    boolean m_stop = false;
    final int sampleRate = 44100;
    int size = sampleRate;
    AudioTrack m_audioTrack = new AudioTrack(AudioManager.STREAM_MUSIC, sampleRate, AudioFormat.CHANNEL_OUT_MONO,
                                           AudioFormat.ENCODING_PCM_FLOAT, sampleRate /* 1 second buffer */,
                                           AudioTrack.MODE_STREAM);;
    Thread m_noiseThread;

    //        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

    Handler handler = new Handler(new Handler.Callback() {
        @Override
        public boolean handleMessage(Message msg) {
            if (eventStream != null) {
                Log.d(TAG, "handleMessage: " + msg.obj);
                eventStream.success(msg.obj);
            }
            return true;
        }
    });


    final static int HighFrequency = 2000;
    final static int MediumFrequency = HighFrequency / 2;
    final static int LowFrequency = MediumFrequency / 2;

    int beatsPerBar = 4;
    int clicksPerBeat = 1;

    Integer currentBeatsPerBar = 1;
    int currentClickPerBeat = 1;

    private EventChannel channel;
    private EventChannel.EventSink eventStream;

    Runnable m_noiseGenerator = new Runnable()
    {
        public void run() {
            Thread.currentThread().setPriority(Thread.MAX_PRIORITY);

            while(!m_stop)
            {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (eventStream != null) {
                            final int copy = currentBeatsPerBar;
                            eventStream.success(copy);
                        }
                    }
                });

                Log.d(TAG, "na poczatku: " + currentBeatsPerBar);
                final float samples[] = new float[size];
                int freq = currentBeatsPerBar == 1
                        ? currentClickPerBeat == 1 ? HighFrequency : LowFrequency
                        : currentClickPerBeat == 1 ? MediumFrequency : LowFrequency;

                for (int i = 0; i < size; ++i) {
                    if (i < sampleRate / 20) {
                        samples[i] = (float) Math.sin(2 * Math.PI * i / (float)(sampleRate / freq)); // Sine wave
                    }
                    else {
                        samples[i] = 0;
                    }
                }

                m_audioTrack.write(samples, 0, samples.length, AudioTrack.WRITE_BLOCKING);

//                Message msg = handler.obtainMessage();
//                msg.obj = currentBeatsPerBar;
//                handler.sendMessage(msg);
//
                Log.d(TAG, "w srodeczku: " + currentBeatsPerBar);





                currentClickPerBeat++;
                if (currentClickPerBeat > clicksPerBeat) {
                    currentClickPerBeat = 1;

                    currentBeatsPerBar++;
                    if (currentBeatsPerBar > beatsPerBar) {
                        currentBeatsPerBar = 1;
                    }
                }

                Log.d(TAG, "na koncu: " + currentBeatsPerBar);

//                runOnUiThread(() -> {
//                    Log.d(TAG, "teraz: " + (currentBeatsPerBar));
//                    if (eventStream != null) {
//                        eventStream.success(currentBeatsPerBar);
//                    }
//
//                    currentClickPerBeat++;
//                    if (currentClickPerBeat > clicksPerBeat) {
//                        currentClickPerBeat = 1;
//
//                        currentBeatsPerBar++;
//                        if (currentBeatsPerBar > beatsPerBar) {
//                            currentBeatsPerBar = 1;
//                        }
//                    }
//                });


            }

        }
    };

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState, @Nullable PersistableBundle persistentState) {
        super.onCreate(savedInstanceState, persistentState);

    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        channel = new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "com.example.metronom/barBeatChannel");
        channel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                eventStream = events;
            }

            @Override
            public void onCancel(Object arguments) {
                Log.d(TAG, "onCancel: ");
                eventStream.endOfStream();
                eventStream = null;
            }
        });

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("start")) {
                        setup(call);
                        start();

                        result.success(null);

                    } else if (call.method.equals("stop")) {
                        stop();
                        result.success(null);

                    } else if (call.method.equals("change")) {
                        stop();

                        try {
                            m_noiseThread.join();
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }

                        setup(call);
                        start();

                        result.success(null);
                    } else if (call.method.equals("smoothChange")) {
                        setup(call);

                        result.success(null);
                    }
                    else {
                        result.notImplemented();
                    }
                }
            );
    }

    private void setup(MethodCall call) throws NullPointerException {
        try {
            int tempo = call.argument("tempo");
            Log.d(TAG, "tempo: " + tempo);

            beatsPerBar = call.argument("beatsPerBar");
            Log.d(TAG, "beatsPerBar: " + beatsPerBar);

            clicksPerBeat = call.argument("clicksPerBeat");
            Log.d(TAG, "clicksPerBeat: " + clicksPerBeat);

            double tempoMultiplier = call.argument("tempoMultiplier");
            Log.d(TAG, "tempoMultiplier: " + tempoMultiplier);

            size = (int) (sampleRate  * (((1 / ( (double) tempo / 60)) / clicksPerBeat) / tempoMultiplier) );
            Log.d(TAG, "size: " + size);
        }
        catch (NullPointerException e) {
            throw e;
        }
    }

    private void start() {
        m_stop = false;
        m_audioTrack.play();

        m_noiseThread = new Thread(m_noiseGenerator);
        m_noiseThread.start();
    }

    private void stop()
    {
        m_stop = true;

        m_audioTrack.pause();
        m_audioTrack.flush();

        currentBeatsPerBar = 1;
        currentClickPerBeat = 1;
        Log.d(TAG, "stop: " + currentBeatsPerBar);
    }
}