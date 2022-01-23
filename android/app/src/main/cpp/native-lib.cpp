#include <jni.h>
#include "AudioEngine.h"



static AudioEngine audioEngine;

extern "C" {
    JNIEXPORT void JNICALL Java_com_example_metronom_SoundPlayer_start(JNIEnv *pEnv, jobject thiz)
    {
        audioEngine.start();
    }

    JNIEXPORT void JNICALL Java_com_example_metronom_SoundPlayer_stop(JNIEnv *pEnv, jobject thiz)
    {
        audioEngine.stop();
    }
}
