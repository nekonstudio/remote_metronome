package com.example.metronom;

import android.content.res.AssetManager;
import android.os.Bundle;

import androidx.annotation.Nullable;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    static {
        System.loadLibrary("native-android-metronome");
    }

    private native void setupAssetManager(AssetManager assetManager);

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setupAssetManager(getAssets());
    }
}