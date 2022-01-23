#include "AudioEngine.h"

using namespace  oboe;

AudioEngine::AudioEngine(/* args */)
{
    AudioStreamBuilder builder;
    builder.setPerformanceMode(PerformanceMode::LowLatency);
    builder.setSharingMode(SharingMode::Exclusive);
    builder.setDataCallback(this);

    Result result = builder.openStream(_stream);

    if (result != Result::OK) {
        LOGE("Nie można otworzyć streamu");
    }
}

AudioEngine::~AudioEngine()
{
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
    if (_stream) {
        _stream->stop();
//        _stream->close();

//        _stream.reset();
    }
}

DataCallbackResult
AudioEngine::onAudioReady(AudioStream *audioStream, void *audioData, int32_t numFrames) {
//    LOGV("numFrames: %d", numFrames);
    // Fill the output buffer with random white noise.
    const int numChannels = _stream->getChannelCount();
//    LOGV("numChannels: %d", numChannels);
    // This code assumes the format is AAUDIO_FORMAT_PCM_FLOAT.
    float *output = (float *)audioData;
    for (int frameIndex = 0; frameIndex < numFrames; frameIndex++) {
        for (int channelIndex = 0; channelIndex < numChannels; channelIndex++) {
            float noise = (float)(drand48()); // add -0.5
            *output++ = noise;
        }
    }
    return DataCallbackResult::Continue;
}
