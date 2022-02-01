#include <jni.h>
#include <android/asset_manager_jni.h>
#include "AudioEngine.h"
#include "LogUtils.h"


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

    JNIEXPORT jboolean JNICALL
    Java_com_example_metronom_SoundPlayer_shouldGoToNextBeat(JNIEnv *env, jobject thiz) {
        return audioEngine.shouldGoToNextBeat();
    }

    JNIEXPORT void JNICALL
    Java_com_example_metronom_SoundPlayer_resetShouldGoToNextBeat(JNIEnv *env, jobject thiz) {
        audioEngine.resetShouldGoToNextBeat();
    }

    JNIEXPORT void JNICALL
    Java_com_example_metronom_SoundPlayer_setMetronomeSettings(JNIEnv *env, jobject thiz, jint tempo,
                                                               jint clicks_per_beat) {
        audioEngine.setMetronomeSettings(tempo, clicks_per_beat);
    }

    JNIEXPORT void JNICALL
    Java_com_example_metronom_SoundPlayer_setupAudioSources(JNIEnv *env, jobject thiz, jobject jAssetManager) {
        AAssetManager *assetManager = AAssetManager_fromJava(env, jAssetManager);
        if (assetManager == nullptr) {
            LOGE("Could not obtain the AAssetManager");
            return;
        }

        audioEngine.setupAudioSources(*assetManager);
    }

    JNIEXPORT void JNICALL
    Java_com_example_metronom_SoundPlayer_setIsSynchronizedMetronome(JNIEnv *env, jobject thiz,
                                                                     jboolean value) {
        audioEngine.setIsSynchronizedMetronome(value);
    }
    JNIEXPORT void JNICALL
    Java_com_example_metronom_SoundPlayer_setPlaySynchronizedMetronome(JNIEnv *env, jobject thiz,
                                                                       jboolean value) {
        audioEngine.setPlaySynchronizedMetronome(value);
    }
}