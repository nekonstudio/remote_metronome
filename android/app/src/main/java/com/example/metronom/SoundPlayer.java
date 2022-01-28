package com.example.metronom;

import android.content.res.AssetManager;

public class SoundPlayer {
    static {
        System.loadLibrary("native-lib");
    }

    public native void start();
    public native void play();
    public native void pause();
    public native void stop();

    public native boolean shouldGoToNextBeat();
    public native void resetShouldGoToNextBeat();

    public native void setMetronomeSettings(int tempo, int clicksPerBeat);

    public native void setSoundBuffer(byte[] buffer, int bufferSize);

    public native void setupAudioSources(AssetManager assetManager);
}
