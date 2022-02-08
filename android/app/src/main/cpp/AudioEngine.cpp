#include "AudioEngine.h"
#include "AudioProperties.h"
#include "AAssetDataSource.h"
#include "LogUtils.h"

#include "NativeAndroidMetronome.h"

using namespace  oboe;

// Double-buffering offers a good tradeoff between latency and protection against glitches.
constexpr int32_t kBufferSizeInBursts = 2;

constexpr int64_t kMillisecondsInSecond = 1000;
constexpr int64_t convertFramesToMillis(const int64_t frames, const int sampleRate){
    return static_cast<int64_t>((static_cast<double>(frames)/ sampleRate) * kMillisecondsInSecond);
}

AudioEngine::AudioEngine(/* args */)
{
    AudioStreamBuilder builder;
    builder.setSampleRate(44100);
    builder.setFormat(AudioFormat::Float);
    builder.setChannelCount(1);
    builder.setPerformanceMode(PerformanceMode::LowLatency);
    builder.setSharingMode(SharingMode::Exclusive);
    builder.setDataCallback(this);

    Result result = builder.openStream(_stream);

    if (result != Result::OK) {
        LOGE("Nie można otworzyć streamu");
    }

    _stream->setBufferSizeInFrames(_stream->getFramesPerBurst() * kBufferSizeInBursts);

    LOGD("Buffer size in frames: %d", _stream->getBufferSizeInFrames());
}

AudioEngine::~AudioEngine()
{
    _stream->close();
    _stream.reset();

    delete _highSoundSource;
    delete _mediumSoundSource;
    delete _lowSoundSource;
}

void AudioEngine::start(int tempo, int clicksPerBeat, int beatsPerBar)
{
    _tempo = tempo;
    _clicksPerBeat = clicksPerBeat;
    _beatsPerBar = beatsPerBar;

    _currentBeatPerBar = 1;
    sendMsgToFlutter(_currentBeatPerBar);

    Result result = _stream->requestStart();

    if (result != Result::OK) {
        LOGE("Nie można wystartować streamu");
    }
}

void AudioEngine::stop()
{
    _framesWritten = 0;
    _isSynchronizedMetronome = false;
    _playSynchronizedMetronome = false;

    _currentBeatPerBar = 0;
    _currentClickPerBeat = 1;
    _previousClicksPerBeat = 1;

    _currentSoundSource = _highSoundSource;

    sendMsgToFlutter(_currentBeatPerBar);

    if (_stream) {
        _stream->requestStop();
    }
}

DataCallbackResult
AudioEngine::onAudioReady(AudioStream *audioStream, void *audioData, int32_t numFrames) {
    auto* outputBuffer = static_cast<float*>(audioData);

    auto sampleRate = audioStream->getSampleRate();
    int framesToPlay = static_cast<int>( sampleRate * ( 1 / ( static_cast<float>(_tempo) / 60 ) / _clicksPerBeat ) );

    auto* readSoundBuffer = _currentSoundSource->getData();
    auto bufferSize = _currentSoundSource->getSize();

    for (int i = 0; i < numFrames; ++i) {
        if (_isSynchronizedMetronome && !_playSynchronizedMetronome) {
            outputBuffer[i] = 0.0f;
        } else {
            if (_framesWritten < bufferSize) {
                outputBuffer[i] = readSoundBuffer[_framesWritten];
            } else {
                outputBuffer[i] = 0.0f;
            }

            _framesWritten++;
            if (_framesWritten >= framesToPlay) {
                _framesWritten = 0;

                handleMetronomeControlData();

                _currentSoundSource = _currentBeatPerBar == 1
                                      ? _currentClickPerBeat == 1 ? _highSoundSource : _lowSoundSource
                                      : _currentClickPerBeat == 1 ? _mediumSoundSource : _lowSoundSource;

                readSoundBuffer = _currentSoundSource->getData();
                bufferSize = _currentSoundSource->getSize();
            }
        }
    }

    return DataCallbackResult::Continue;
}

bool AudioEngine::onError(oboe::AudioStream *audioStream, oboe::Result result) {
//    if (result == oboe::Result::ErrorDisconnected) {
//        std::function<void(void)> restartFunction = std::bind(&AudioEngine::restart, this);
//        new std::thread(restartFunction);
//    }
    return AudioStreamErrorCallback::onError(audioStream, result);
}

void AudioEngine::setupAudioSources(AAssetManager &assetManager) {
    AudioProperties targetProperties {
            .channelCount = _stream->getChannelCount(),
            .sampleRate = _stream->getSampleRate()
    };

    _highSoundSource = AAssetDataSource::newFromCompressedAsset(assetManager, "click_high.wav", targetProperties);
    _mediumSoundSource = AAssetDataSource::newFromCompressedAsset(assetManager, "click_medium.wav", targetProperties);
    _lowSoundSource = AAssetDataSource::newFromCompressedAsset(assetManager, "click_low.wav", targetProperties);

    _currentSoundSource = _highSoundSource;


    LOGD("Data source size: %d", _highSoundSource->getSize());
}

void AudioEngine::handleMetronomeControlData() {
    _currentClickPerBeat++;

//    // switch to next beat when clicksPerBeat setting changed to higher value while playing
//    if (_previousClicksPerBeat < _clicksPerBeat) {
//        nextBeatPerBar();
//
//        _previousClicksPerBeat = _clicksPerBeat;
//    }
//    else
        if (_currentClickPerBeat > _clicksPerBeat) {
        nextBeatPerBar();
    }
}

void AudioEngine::nextBeatPerBar() {
    _currentClickPerBeat = 1;
    _currentBeatPerBar++;
    if (_currentBeatPerBar > _beatsPerBar) {
        _currentBeatPerBar = 1;
    }

    sendMsgToFlutter(_currentBeatPerBar);
}