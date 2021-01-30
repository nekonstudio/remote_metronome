package com.example.metronom;

import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.util.Log;
import android.util.SparseArray;

import androidx.annotation.NonNull;

import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import io.flutter.FlutterInjector;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.metronom/metronom";
    private static final String TAG = "MetronomePlugin";

    boolean m_stop = false;
    final int sampleRate = 44100;
//    final int sampleRate = 48000;
    int size = sampleRate;

//        AudioFormat audioFormat = new AudioFormat.Builder()
//                .setSampleRate(sampleRate)
//                .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
//                .setChannelMask(AudioFormat.CHANNEL_OUT_MONO).build();
//        AudioAttributes attributes = new AudioAttributes.Builder()
//                .setUsage(AudioAttributes.USAGE_MEDIA)
//                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build();
//        AudioTrack at = new AudioTrack.Builder()
//                .setAudioFormat(audioFormat)
//                .setAudioAttributes(attributes)
//                .setBufferSizeInBytes(minBufferSize).build();

    AudioTrack m_audioTrack = new AudioTrack(
            AudioManager.STREAM_MUSIC,
            sampleRate,
            AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            AudioTrack.getMinBufferSize(sampleRate,
                    AudioFormat.CHANNEL_OUT_MONO,
                    AudioFormat.ENCODING_PCM_16BIT),
            AudioTrack.MODE_STREAM);

    Thread m_metronomeThread;
    Thread m_syncMetronomeThread;

    final static int HighSound = 1;
    final static int MediumSound = 2;
    final static int LowSound = 3;

    final SparseArray<byte[]> m_soundBuffers = new SparseArray<byte[]>() {{
        put(HighSound, null);
        put(MediumSound, null);
        put(LowSound, null);
    }};

    int beatsPerBar = 4;
    int clicksPerBeat = 1;

    Integer currentBeatsPerBar = 1;
    int currentClickPerBeat = 1;

    boolean m_syncPlayMetronome = false;

    private EventChannel.EventSink eventStream;
    private EventChannel.EventSink latencyEventStream;

    boolean logFirstSoundPlayTime = false;

    Runnable m_metronomePlayer = new Runnable()
    {
        public void run() {
            Thread.currentThread().setPriority(Thread.MAX_PRIORITY);

            Date currentTime = Calendar.getInstance().getTime();
            SimpleDateFormat sdf = new SimpleDateFormat("hh:mm:ss.SSS");
            Log.d(TAG, "currentTime: " + sdf.format(currentTime));



            while(!m_stop)
            {
                runOnUiThread(() -> {
                    if (eventStream != null) {
                        final int copy = currentBeatsPerBar;
                        eventStream.success(copy);
                    }
                });

                int soundId = currentBeatsPerBar == 1
                        ? currentClickPerBeat == 1 ? HighSound : LowSound
                        : currentClickPerBeat == 1 ? MediumSound : LowSound;

                int bufferSize = size * 2;
                byte[] samples = new byte[bufferSize];
                byte[] buffer = m_soundBuffers.get(soundId);

//                long startTime = SystemClock.elapsedRealtime();
                for (int i = 0; i < bufferSize; ++i) {

                    if (i < buffer.length) {
                        samples[i] = buffer[i];
                    }
                    else {
                        samples[i] = 0;
                    }
                }

                if (logFirstSoundPlayTime) {
                    currentTime = Calendar.getInstance().getTime();
                    Log.d(TAG, "time before play: " + sdf.format(currentTime));

                    long timestamp = System.currentTimeMillis();

                    runOnUiThread(() -> {
                        if (latencyEventStream != null) {
                            latencyEventStream.success(timestamp);
                        }
                    });

                    logFirstSoundPlayTime = false;
                }



                m_audioTrack.write(samples, 0, samples.length);

//                if (logFirstSoundPlayTime) {
//                    currentTime = Calendar.getInstance().getTime();
//                    Log.d(TAG, "time after play: " + sdf.format(currentTime));
//
//                    logFirstSoundPlayTime = false;
//                }

                currentClickPerBeat++;
                if (currentClickPerBeat > clicksPerBeat) {
                    currentClickPerBeat = 1;

                    currentBeatsPerBar++;
                    if (currentBeatsPerBar > beatsPerBar) {
                        currentBeatsPerBar = 1;
                    }
                }
            }

        }
    };

    Runnable m_syncMetronomePlayer = new Runnable()
    {
        public void run() {
            Thread.currentThread().setPriority(Thread.MAX_PRIORITY);

            while(!m_stop)
            {
                runOnUiThread(() -> {
                    if (eventStream != null) {
                        final int copy = currentBeatsPerBar;
                        eventStream.success(copy);
                    }
                });

                int soundId = currentBeatsPerBar == 1
                        ? currentClickPerBeat == 1 ? HighSound : LowSound
                        : currentClickPerBeat == 1 ? MediumSound : LowSound;

                int bufferSize = size * 2;
                byte[] samples = new byte[bufferSize];
                byte[] buffer = m_soundBuffers.get(soundId);

//                long startTime = SystemClock.elapsedRealtime();
                for (int i = 0; i < bufferSize; ++i) {

                    if (i < buffer.length) {
                        samples[i] = buffer[i];
                    }
                    else {
                        samples[i] = 0;
                    }
                }

                while (!m_syncPlayMetronome) {
                    android.os.SystemClock.sleep(1);
                }

                if (logFirstSoundPlayTime) {
                    long timestamp = System.currentTimeMillis();

                    runOnUiThread(() -> {
                        if (latencyEventStream != null) {
                            latencyEventStream.success(timestamp);
                        }
                    });

                    logFirstSoundPlayTime = false;
                }

                m_audioTrack.write(samples, 0, samples.length);

                currentClickPerBeat++;
                if (currentClickPerBeat > clicksPerBeat) {
                    currentClickPerBeat = 1;

                    currentBeatsPerBar++;
                    if (currentBeatsPerBar > beatsPerBar) {
                        currentBeatsPerBar = 1;
                    }
                }
            }

            m_syncPlayMetronome = false;

        }
    };

    public void fillSoundBuffers(){
        SparseArray<String> fileNames = new SparseArray<String>() {{
            put(HighSound, "click_high.wav");
            put(MediumSound, "click_medium.wav");
            put(LowSound, "click_low.wav");
        }};

        FlutterLoader loader = FlutterInjector.instance().flutterLoader();

        for (int i = 0; i < m_soundBuffers.size(); ++i) {
            int soundId = m_soundBuffers.keyAt(i);
            String fileName = fileNames.get(soundId);

            try {
                String key = loader.getLookupKeyForAsset("assets/sounds/" + fileName);
                AssetFileDescriptor fileDescriptor = getAssets().openFd(key);
                FileInputStream fin = fileDescriptor.createInputStream();
                fin.skip(734); // skip 734 header bytes (dunno why not 44)
                DataInputStream dis = new DataInputStream(fin);
                ByteArrayOutputStream out = new ByteArrayOutputStream();

                int bytesRead;
                final int bufferSize = 1024;
                byte[] s = new byte[bufferSize];
                while((bytesRead = dis.read(s, 0, bufferSize)) > -1){
                    out.write(s, 0, bytesRead);
                }

                m_soundBuffers.setValueAt(m_soundBuffers.indexOfKey(soundId), out.toByteArray());

                dis.close();
                fin.close();
                out.close();

            } catch (IOException e) {
                // TODO
                e.printStackTrace();
            }
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        fillSoundBuffers();

        EventChannel channel = new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "com.example.metronom/barBeatChannel");
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

        EventChannel latencyChannel = new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "com.example.metronom/platformLatencyChannel");
        latencyChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                latencyEventStream = events;
            }

            @Override
            public void onCancel(Object arguments) {
                Log.d(TAG, "onCancel: ");
                latencyEventStream.endOfStream();
                latencyEventStream = null;
            }
        });

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "test":
//                            setup(call);
//                            Log.d(TAG, "configureFlutterEngine: ERLOOOO");
                            result.success(null);
                            break;
                        case "start":

                            setup(call);
                            start();

                            result.success(null);

                            break;

                        case "syncStartPrepare":
                            setup(call);
                            syncStart();

                            break;

                        case "syncStart":
                            m_syncPlayMetronome = true;
                            break;


                        case "stop":
                            stop();
                            result.success(null);

                            break;
                        case "change":
                            stop();

                            try {
                                m_metronomeThread.join();
                            } catch (InterruptedException e) {
                                e.printStackTrace();
                            }

                            setup(call);
                            start();

                            result.success(null);
                            break;
                        case "smoothChange":
                            setup(call);

                            result.success(null);
                            break;
                        default:
                            Log.d(TAG, "method name: " + call.method);
                            result.notImplemented();
                            break;
                    }
                }
            );
    }

    private void setup(MethodCall call) throws NullPointerException {
        try {
            int tempo = call.argument("tempo");
//            Log.d(TAG, "tempo: " + tempo);

            beatsPerBar = call.argument("beatsPerBar");
//            Log.d(TAG, "beatsPerBar: " + beatsPerBar);

            clicksPerBeat = call.argument("clicksPerBeat");
//            Log.d(TAG, "clicksPerBeat: " + clicksPerBeat);

            double tempoMultiplier = call.argument("tempoMultiplier");
//            Log.d(TAG, "tempoMultiplier: " + tempoMultiplier);

            size = (int) (sampleRate  * (((1 / ( (double) tempo / 60)) / clicksPerBeat) / tempoMultiplier) );
//            Log.d(TAG, "size: " + size);
        }
        catch (NullPointerException e) {
            throw e;
        }
    }

    private void start() {
        m_stop = false;

        AudioManager am = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
        String sampleRateStr = am.getProperty(AudioManager.PROPERTY_OUTPUT_SAMPLE_RATE);
        int sp = Integer.parseInt(sampleRateStr);
        Log.d(TAG, "sampleRate: " + sp);

        m_audioTrack.play();

        logFirstSoundPlayTime = true;

        m_metronomeThread = new Thread(m_metronomePlayer);
        m_metronomeThread.start();
    }

    private void syncStart() {
        m_stop = false;

        m_audioTrack.play();

        m_syncPlayMetronome = false;
        logFirstSoundPlayTime = true;

        m_syncMetronomeThread = new Thread(m_syncMetronomePlayer);
        m_syncMetronomeThread.start();
    }

    private void stop()
    {
        m_stop = true;

        m_audioTrack.pause();
        m_audioTrack.flush();

        currentBeatsPerBar = 1;
        currentClickPerBeat = 1;

        logFirstSoundPlayTime = false;

        eventStream.success(0);
        Log.d(TAG, "stop: " + currentBeatsPerBar);
    }
}