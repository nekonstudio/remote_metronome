#include <oboe/Oboe.h>

#include <android/log.h>
#include <android/asset_manager.h>
#include "Oscillator.h"
#include "AAssetDataSource.h"

class AudioEngine : public oboe::AudioStreamDataCallback, public oboe::AudioStreamErrorCallback
{
public:
    AudioEngine(/* args */);
    ~AudioEngine();

    void start();
    void stop();
    void restart();
    void setToneOn(bool isToneOn);
    bool shouldGoToNextBeat();
    void resetShouldGoToNextBeat();

    void setMetronomeSettings(int32_t tempo, int32_t clicksPerBeat);

    void setSoundBuffer(int8_t* buffer, int bufferSize);

    void setupAudioSources(AAssetManager &assetManager);

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

    AAssetDataSource* _dataSource = nullptr;

//    float* _soundBuffer;
    int _bufferSize;
};
