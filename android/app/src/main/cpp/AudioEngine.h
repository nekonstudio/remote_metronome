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
    bool shouldGoToNextBeat();
    void resetShouldGoToNextBeat();

    void setMetronomeSettings(int32_t tempo, int32_t clicksPerBeat);

    void setupAudioSources(AAssetManager &assetManager);

    oboe::DataCallbackResult
    onAudioReady(oboe::AudioStream *audioStream, void *audioData, int32_t numFrames) override;

    bool onError(oboe::AudioStream *audioStream, oboe::Result result) override;

    void setIsSynchronizedMetronome(bool value) { _isSynchronizedMetronome = value; }
    void setPlaySynchronizedMetronome(bool value) { _playSynchronizedMetronome = value; }
    void setCurrentMetronomeValues(int currentBeatPerBar, int currentClickPerBeat) {
        _currentBeatPerBar = currentBeatPerBar;
        _currentClickPerBeat = currentClickPerBeat;
    };


private:
    std::shared_ptr<oboe::AudioStream> _stream;

    int32_t _framesWritten = 0;
    std::atomic<bool> _shouldGoToNextBeat {false};
    std::atomic<bool> _isSynchronizedMetronome {false};
    std::atomic<bool> _playSynchronizedMetronome {false};
    std::atomic<int> _currentBeatPerBar { 0 };
    std::atomic<int> _currentClickPerBeat { 0 };

    int32_t _tempo;
    int32_t _clicksPerBeat;

    AAssetDataSource* _highSoundSource = nullptr;
    AAssetDataSource* _mediumSoundSource = nullptr;
    AAssetDataSource* _lowSoundSource = nullptr;
};
