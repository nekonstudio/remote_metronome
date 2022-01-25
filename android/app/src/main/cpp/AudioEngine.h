#include <oboe/Oboe.h>

#include <android/log.h>
#include "Oscillator.h"

#define TAG "AudioEngine"
#define  LOGV(...)  __android_log_print(ANDROID_LOG_VERBOSE,    TAG, __VA_ARGS__)
#define  LOGW(...)  __android_log_print(ANDROID_LOG_WARN,       TAG, __VA_ARGS__)
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,      TAG, __VA_ARGS__)
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO,       TAG, __VA_ARGS__)
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR,      TAG, __VA_ARGS__)

class AudioEngine : public oboe::AudioStreamDataCallback, public oboe::AudioStreamErrorCallback
{
public:
    AudioEngine(/* args */);
    ~AudioEngine();

    void load();

    void start();
    void stop();
    void restart();
    void setToneOn(bool isToneOn);
    bool shouldGoToNextBeat();
    void resetShouldGoToNextBeat();

    void setMetronomeSettings(int32_t tempo, int32_t clicksPerBeat);

    void setSoundBuffer(int8_t* buffer, int bufferSize);

    oboe::DataCallbackResult
    onAudioReady(oboe::AudioStream *audioStream, void *audioData, int32_t numFrames) override;

    bool onError(oboe::AudioStream *audioStream, oboe::Result result) override;


private:
    std::shared_ptr<oboe::AudioStream> _stream;
    Oscillator _oscillator;

    int32_t _framesWritten = 0;
    std::atomic<bool> _shouldGoToNextBeat {false};

    int32_t _tempo;
    int32_t _clicksPerBeat;

    int _currentClickPerBar = 0;

    int8_t* _soundBuffer;
    int _bufferSize;
};
