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
    void change(int tempo, int clicksPerBeat, bool immediate);
    void requestStop(bool immediate);

    void prepareSynchronizedStart(int tempo, int clicksPerBeat, int beatsPerBar);
    void runSynchronizedStart() { _playSynchronizedMetronome = true; }

    void setupAudioSources(AAssetManager &assetManager);

    oboe::DataCallbackResult
    onAudioReady(oboe::AudioStream *audioStream, void *audioData, int32_t numFrames) override;

    bool onError(oboe::AudioStream *audioStream, oboe::Result result) override;

private:
    void stop();
    void handleMetronomeControlData();
    void nextBeatPerBar();

    std::shared_ptr<oboe::AudioStream> _stream;

    int32_t _framesWritten = 0;
    std::atomic<bool> _isSynchronizedMetronome {false};
    std::atomic<bool> _playSynchronizedMetronome {false};
    std::atomic<int> _currentBeatPerBar { 0 };
    std::atomic<int> _currentClickPerBeat { 1 };
    std::atomic<int> _previousClicksPerBeat { 1};

    std::atomic<bool> _isStopRequested {false};
    std::atomic<bool> _isChangePending {false};
    std::atomic<bool> _waitToEndToStop {false};

    int _tempo;
    int _clicksPerBeat;
    int _beatsPerBar;

    int _pendingTempo;
    int _pendingClicksPerBeat;

    AAssetDataSource* _currentSoundSource = nullptr;

    AAssetDataSource* _highSoundSource = nullptr;
    AAssetDataSource* _mediumSoundSource = nullptr;
    AAssetDataSource* _lowSoundSource = nullptr;
};
