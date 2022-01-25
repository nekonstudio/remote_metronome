#include "AudioEngine.h"

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
}

AudioEngine::~AudioEngine()
{
}



void AudioEngine::start()
{
    AudioStreamBuilder builder;
    builder.setFormat(AudioFormat::I16);
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

    result = _stream->requestStart();

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
        _stream->close();

        _stream.reset();
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
    auto* outputBuffer = static_cast<int16_t*>(audioData);

    auto sampleRate = audioStream->getSampleRate();
    int framesToPlay = static_cast<int>( sampleRate * ( 1 / ( static_cast<float>(_tempo) / 60 ) / _clicksPerBeat ) );
//    LOGD("framesToPlay: %d", framesToPlay);

    auto timePlayedInMills = convertFramesToMillis(numFrames + _framesWritten, sampleRate);
//    LOGD("timePlayedInMills: %d", timePlayedInMills);

//    if (timePlayedInMills < 100) {
////        _oscillator.render(outputBuffer, numFrames);
//
//        for (int i = 0; i < numFrames; ++i) {
//            outputBuffer[i] = _soundBuffer[i];
//        }
//    } else {
//        for (int i = 0; i < numFrames; ++i) {
//            outputBuffer[i] = 0;
//        }
//    }

    for (int i = 0; i < numFrames; ++i) {
        if (_framesWritten < _bufferSize) {
            outputBuffer[_framesWritten] = _soundBuffer[_framesWritten];
        } else {
            outputBuffer[_framesWritten] = 0;
        }

        LOGD("Data written: %d, Index: %d", outputBuffer[_framesWritten], _framesWritten);

        _framesWritten++;
    }

//    _framesWritten += numFrames;
//    LOGD("_framesWritten: %d", _framesWritten);
    if (_framesWritten >= framesToPlay) {
        _framesWritten = 0;
        _shouldGoToNextBeat = true;

//        _currentClickPerBar++;
//        LOGD("currentClickPerBar: %d", _currentClickPerBar);
//        if (_currentClickPerBar >= _clicksPerBeat) {
//            LOGD("DALEJ!");
//            _shouldGoToNextBeat = true;
//            _currentClickPerBar = 0;
//        }
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
    _soundBuffer = buffer;
    _bufferSize = bufferSize;
}

void AudioEngine::load() {

}
