#include "AudioEngine.h"

static AudioEngine audioEngine;

extern "C" {
    void start() {
        audioEngine.start();
    }

    void stop() {
        audioEngine.stop();
    }
}