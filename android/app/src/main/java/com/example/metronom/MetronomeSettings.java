package com.example.metronom;

import io.flutter.plugin.common.MethodCall;

class MetronomeSettings {
    final int tempo;
    final int beatsPerBar;
    final int clicksPerBeat;

    MetronomeSettings(int tempo, int beatsPerBar, int clicksPerBeat) {
        this.tempo = tempo;
        this.beatsPerBar = beatsPerBar;
        this.clicksPerBeat = clicksPerBeat;
    }

    static MetronomeSettings fromMethodCall(MethodCall call) {
        return new MetronomeSettings(
                call.argument("tempo"),
                call.argument("beatsPerBar"),
                call.argument("clicksPerBeat")
        );
    }
}
