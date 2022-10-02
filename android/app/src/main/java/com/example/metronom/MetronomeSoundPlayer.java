package com.example.metronom;

import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.media.audiofx.LoudnessEnhancer;
import android.util.Log;

import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.loader.FlutterLoader;

class MetronomeSoundPlayer {

    private static final String TAG = "MetronomeSoundPlayer";

    enum SoundId {
        HIGH_SOUND,
        MEDIUM_SOUND,
        LOW_SOUND,
    }

    private final static int SOUND_SAMPLE_RATE = 44100;

    private final AudioTrack _audioTrack = new AudioTrack(
            AudioManager.STREAM_MUSIC,
            SOUND_SAMPLE_RATE,
            AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            AudioTrack.getMinBufferSize(SOUND_SAMPLE_RATE,
                    AudioFormat.CHANNEL_OUT_MONO,
                    AudioFormat.ENCODING_PCM_16BIT),
            AudioTrack.MODE_STREAM);

    private final LoudnessEnhancer loudnessEnhancer;

    private final Map<SoundId, byte[]> _soundBuffers = new HashMap<>();

    private byte[] _currentSoundData;
    private int _currentSoundDataLength;

    MetronomeSoundPlayer() {
        loudnessEnhancer = new LoudnessEnhancer(_audioTrack.getAudioSessionId());
        loudnessEnhancer.setTargetGain(500);
        loudnessEnhancer.setEnabled(true);
    }

    void loadSoundsFromAssets(AssetManager assets) {
        final Map<SoundId, String> soundFileNames = new HashMap<SoundId, String>() {{
            put(SoundId.HIGH_SOUND, "click_high.wav");
            put(SoundId.MEDIUM_SOUND, "click_medium.wav");
            put(SoundId.LOW_SOUND, "click_low.wav");
        }};


        for (Map.Entry<SoundId, String> entry : soundFileNames.entrySet()) {
            try {
                final String fileName = entry.getValue();
                final FlutterLoader loader = FlutterInjector.instance().flutterLoader();
                final String assetKey = loader.getLookupKeyForAsset("assets/sounds/" + fileName);
                final AssetFileDescriptor fileDescriptor = assets.openFd(assetKey);
                final FileInputStream fileInputStream = fileDescriptor.createInputStream();

                fileInputStream.skip(734); // skip 734 header bytes (dunno why not 44)
                final DataInputStream dataInputStream = new DataInputStream(fileInputStream);

                int bytesRead;
                final int readBufferSize = 1024;
                byte[] readBuffer = new byte[readBufferSize];
                final ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                while((bytesRead = dataInputStream.read(readBuffer, 0, readBufferSize)) > -1){
                    byteArrayOutputStream.write(readBuffer, 0, bytesRead);
                }

                final SoundId soundId = entry.getKey();
                final byte[] soundData = byteArrayOutputStream.toByteArray();

                _soundBuffers.put(soundId, soundData);

                byteArrayOutputStream.close();
                dataInputStream.close();
                fileInputStream.close();

            } catch (IOException e) {
                // TODO
                e.printStackTrace();
            }
        }
    }

    void configure(MetronomeSettings metronomeSettings) {
        _currentSoundDataLength = (int) (SOUND_SAMPLE_RATE * (((1 / ( (double) metronomeSettings.tempo / 60)) / metronomeSettings.clicksPerBeat) ) );
    }

    void start() {
        _audioTrack.play();
    }

    void stop() {
        _audioTrack.pause();
        _audioTrack.flush();
    }

    void generateCurrentSound(int currentBeatsPerBar, int currentClickPerBeat) {
        SoundId soundId = currentBeatsPerBar == 1
                ? currentClickPerBeat == 1 ? SoundId.HIGH_SOUND : SoundId.LOW_SOUND
                : currentClickPerBeat == 1 ? SoundId.MEDIUM_SOUND : SoundId.LOW_SOUND;

        int currentSoundBufferSize = _currentSoundDataLength * 2;
        _currentSoundData = new byte[currentSoundBufferSize];
        byte[] soundBuffer = _soundBuffers.get(soundId);

        for (int i = 0; i < currentSoundBufferSize; ++i) {
            if (i < soundBuffer.length) {
                _currentSoundData[i] = soundBuffer[i];
            }
            else {
                _currentSoundData[i] = 0;
            }
        }
    }

    void playCurrentSound() {
        _audioTrack.write(_currentSoundData, 0, _currentSoundData.length);
    }
}
