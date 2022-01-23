package com.example.metronom;

public class SoundPlayer {
    static {
        System.loadLibrary("native-lib");
    }

    public native void start();
    public native void stop();
}
