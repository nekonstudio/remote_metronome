#include <jni.h>
#include <android/asset_manager_jni.h>
#include "LogUtils.h"
#include "AudioEngine.h"

#include "include/dart_native_api.h"
#include "include/dart_api_dl.c"

AudioEngine audioEngine;

extern "C" int64_t InitializeDartApi(void *data)
{
    auto result = Dart_InitializeApiDL(data);
    LOGD("%s", "Init result:" + result);
    return result;
}

static int64_t DartApiMessagePort = -1;

extern "C" void SetDartApiMessagePort(int64_t port)
{
    DartApiMessagePort = port;
}

void sendMsgToFlutter(int64_t msg)
{
    if (DartApiMessagePort == -1)
        return;

    Dart_CObject obj;
    obj.type = Dart_CObject_kInt64;
    obj.value.as_int64 = msg;

    Dart_PostCObject_DL(DartApiMessagePort, &obj);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_example_metronom_MainActivity_setupAssetManager(JNIEnv *env, jobject thiz,
                                                         jobject asset_manager) {
    AAssetManager* assetManager = AAssetManager_fromJava(env, asset_manager);
    if (assetManager == nullptr) {
        LOGE("Could not obtain the AAssetManager");
        return;
    }

    audioEngine.setupAudioSources(*assetManager);
}

extern "C" {

    void start(int tempo, int clicksPerBeat, int beatsPerBar) {
        audioEngine.start(tempo, clicksPerBeat, beatsPerBar);
    }

    void stop() {
        audioEngine.stop();
    }
}