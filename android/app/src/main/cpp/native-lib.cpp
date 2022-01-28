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

    JNIEXPORT void JNICALL Java_com_example_metronom_SoundPlayer_play(JNIEnv *pEnv, jobject thiz)
    {
        audioEngine.setToneOn(true);
    }

    JNIEXPORT void JNICALL Java_com_example_metronom_SoundPlayer_pause(JNIEnv *pEnv, jobject thiz)
    {
        audioEngine.setToneOn(false);
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

//    JNIEXPORT void JNICALL
//    Java_com_example_metronom_SoundPlayer_setSoundBuffer(JNIEnv *env, jobject thiz, jbyteArray buffer) {
//        jbyte* bufferPtr = env->GetByteArrayElements(buffer, NULL);
//
//        audioEngine.setSoundBuffer(bufferPtr);
//    }

    JNIEXPORT void JNICALL
    Java_com_example_metronom_SoundPlayer_setSoundBuffer(JNIEnv *env, jobject thiz, jbyteArray buffer,
                                                         jint buffer_size) {
        jbyte* bufferPtr = env->GetByteArrayElements(buffer, NULL);

        audioEngine.setSoundBuffer(bufferPtr, buffer_size);
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
}