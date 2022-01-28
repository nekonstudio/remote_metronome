#include "AudioEngine.h"
#include "AudioProperties.h"
#include "AAssetDataSource.h"
#include "LogUtils.h"

using namespace  oboe;

// Double-buffering offers a good tradeoff between latency and protection against glitches.
constexpr int32_t kBufferSizeInBursts = 2;

constexpr int64_t kMillisecondsInSecond = 1000;
constexpr int64_t convertFramesToMillis(const int64_t frames, const int sampleRate){
    return static_cast<int64_t>((static_cast<double>(frames)/ sampleRate) * kMillisecondsInSecond);
}

AudioEngine::AudioEngine(/* args */)
{
    _oscillator.setWaveOn(true);

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

    _oscillator.setSampleRate(_stream->getSampleRate());
    LOGD("sampleRate: %d", _stream->getSampleRate());

    _stream->setBufferSizeInFrames(_stream->getFramesPerBurst() * kBufferSizeInBursts);

    LOGD("Buffer size in frames: %d", _stream->getBufferSizeInFrames());
}

AudioEngine::~AudioEngine()
{
    _stream->close();

    _stream.reset();

    delete _dataSource;
}



void AudioEngine::start()
{


    Result result = _stream->requestStart();

    if (result != Result::OK) {
        LOGE("Nie można wystartować streamu");
    }
}

void AudioEngine::stop()
{
    _currentClickPerBar = 0;
    _framesWritten = 0;
    _shouldGoToNextBeat = true;

    if (_stream) {
        _stream->requestStop();
//        _stream->close();

//        _stream.reset();
    }
}

void AudioEngine::restart() {
    static std::mutex restartingLock;
    if (restartingLock.try_lock()) {
        stop();
        start();

        restartingLock.unlock();
    }
}

void AudioEngine::setToneOn(bool isToneOn) {
    _oscillator.setWaveOn(isToneOn);
}

DataCallbackResult
AudioEngine::onAudioReady(AudioStream *audioStream, void *audioData, int32_t numFrames) {
    auto* outputBuffer = static_cast<float*>(audioData);

    auto sampleRate = audioStream->getSampleRate();
//    auto sampleRate = 44100;
    int framesToPlay = static_cast<int>( sampleRate * ( 1 / ( static_cast<float>(_tempo) / 60 ) / _clicksPerBeat ) );
//    LOGD("framesToPlay: %d", framesToPlay);


    auto* readSoundBuffer = _dataSource->getData();
    auto bufferSize = _dataSource->getSize();

    for (int i = 0; i < numFrames; ++i) {

//        outputBuffer[_framesWritten] = _framesWritten < bufferSize ? readSoundBuffer[_framesWritten] : 0.0f;
        if (_framesWritten < bufferSize) {
            outputBuffer[i] =  readSoundBuffer[_framesWritten];
            if (_framesWritten == 0) {
                LOGD("First sound data written: %.3f, Index: %d", outputBuffer[i], _framesWritten);
            }
            else if (_framesWritten == bufferSize - 1) {
                LOGD("Last sound data written: %.3f, Index: %d", outputBuffer[i], _framesWritten);
            }



//        }
        } else {
            outputBuffer[i] = 0.0f;
            if (_framesWritten == bufferSize) {
                LOGD("First silence data: %.3f, index: %d", outputBuffer[i], _framesWritten);
            }
            else if (_framesWritten == framesToPlay) {
                LOGD("Last silence data: %.3f, index: %d", outputBuffer[i], _framesWritten);
            }

//            return DataCallbackResult::Stop;
        }

//        LOGD("Data written: %.3f, Index: %d", outputBuffer[_framesWritten], _framesWritten);

        _framesWritten++;

        if (_framesWritten >= framesToPlay) {

//        for (int i = 0; i < 1500; ++i) {
//            LOGD("written data: %.3f, index: %d", outputBuffer[i], i);
//        }

            _framesWritten = 0;
            _shouldGoToNextBeat = true;

            LOGD("DALEJ DALEJ METRONOMIE GADŻETA");
//        return DataCallbackResult::Stop;
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

bool AudioEngine::shouldGoToNextBeat() {
    return _shouldGoToNextBeat;
}

void AudioEngine::resetShouldGoToNextBeat() {
    _shouldGoToNextBeat = false;
}

void AudioEngine::setMetronomeSettings(int32_t tempo, int32_t clicksPerBeat) {
    _tempo = tempo;
    _clicksPerBeat = clicksPerBeat;
}

void AudioEngine::setSoundBuffer(int8_t *buffer, int bufferSize) {
//    _soundBuffer = buffer;
//    _bufferSize = bufferSize;
}

void AudioEngine::setupAudioSources(AAssetManager &assetManager) {
    // Set the properties of our audio source(s) to match that of our audio stream
    AudioProperties targetProperties {
            .channelCount = _stream->getChannelCount(),
//            .channelCount = 1,
            .sampleRate = _stream->getSampleRate()
//            .sampleRate = 44100
    };

    // Create a data source and player for the clap sound
//    _dataSource = std::shared_ptr<AAssetDataSource>{
//            AAssetDataSource::newFromCompressedAsset(assetManager, "click_high.wav", targetProperties)
//    };

    _dataSource = AAssetDataSource::newFromCompressedAsset(assetManager, "click_high.wav", targetProperties);


    LOGD("Data source size: %d", _dataSource->getSize());

    auto* data = _dataSource->getData();

//    for (int i = 0; i < _dataSource->getSize(); ++i) {
//        LOGD("Data: %.3f, Index: %d", data[i], i);
//    }


//    _dataSource = std::make_shared<AAssetDataSource>(AAssetDataSource::newFromCompressedAsset(assetManager, "click_high.wav", targetProperties));

//    mClap = std::make_unique<Player>(mClapSource);
}
