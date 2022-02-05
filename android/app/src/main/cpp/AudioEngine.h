#include <oboe/Oboe.h>

#include <android/log.h>
#include <android/asset_manager.h>
#include "Oscillator.h"
#include "AAssetDataSource.h"

class AudioEngine : public oboe::AudioStreamDataCallback, public oboe::AudioStreamErrorCallback
{
public:
    AudioEngine();
    ~AudioEngine();

    void start(int tempo, int clicksPerBeat, int beatsPerBar);
    void stop();

    void setupAudioSources(AAssetManager &assetManager);

    oboe::DataCallbackResult
    onAudioReady(oboe::AudioStream *audioStream, void *audioData, int32_t numFrames) override;

    bool onError(oboe::AudioStream *audioStream, oboe::Result result) override;

private:
    void handleMetronomeControlData();
    void nextBeatPerBar();

    std::shared_ptr<oboe::AudioStream> _stream;

    int32_t _framesWritten = 0;
    std::atomic<bool> _isSynchronizedMetronome {false};
    std::atomic<bool> _playSynchronizedMetronome {false};
    std::atomic<int> _currentBeatPerBar { 0 };
    std::atomic<int> _currentClickPerBeat { 1 };
    std::atomic<int> _previousClicksPerBeat { 1};

    int _tempo;
    int _clicksPerBeat;
    int _beatsPerBar;

    AAssetDataSource* _currentSoundSource = nullptr;

    AAssetDataSource* _highSoundSource = nullptr;
    AAssetDataSource* _mediumSoundSource = nullptr;
    AAssetDataSource* _lowSoundSource = nullptr;
};
