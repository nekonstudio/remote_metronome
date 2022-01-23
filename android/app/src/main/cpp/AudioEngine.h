#include <oboe/Oboe.h>

#include <android/log.h>
#define TAG "AudioEngine"
#define  LOGV(...)  __android_log_print(ANDROID_LOG_VERBOSE,    TAG, __VA_ARGS__)
#define  LOGW(...)  __android_log_print(ANDROID_LOG_WARN,       TAG, __VA_ARGS__)
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,      TAG, __VA_ARGS__)
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO,       TAG, __VA_ARGS__)
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR,      TAG, __VA_ARGS__)

class AudioEngine : public oboe::AudioStreamCallback
{
public:
    AudioEngine(/* args */);
    ~AudioEngine();

    void start();
    void stop();

    oboe::DataCallbackResult
    onAudioReady(oboe::AudioStream *audioStream, void *audioData, int32_t numFrames) override;

private:
    std::shared_ptr<oboe::AudioStream> _stream;
};
