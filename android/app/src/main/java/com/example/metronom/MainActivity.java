package com.example.metronom;

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

    private EventChannel.EventSink eventStream;

    Runnable m_metronomePlayer = new Runnable()
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

                int testSize = size * 2;
                byte[] samples = new byte[testSize];
                byte[] buffer = m_soundBuffers.get(soundId);
                for (int i = 0; i < testSize; ++i) {

                    if (i < buffer.length) {
                        samples[i] = buffer[i];
                    }
                    else {
                        samples[i] = 0;
                    }
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

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "start":
                            setup(call);
                            start();

                            result.success(null);

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
                            result.notImplemented();
                            break;
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

        m_metronomeThread = new Thread(m_metronomePlayer);
        m_metronomeThread.start();
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