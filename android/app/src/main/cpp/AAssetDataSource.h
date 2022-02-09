//
// Created by Sebastian Lisiecki on 27/01/2022.
//

#ifndef ANDROID_AASSETDATASOURCE_H
#define ANDROID_AASSETDATASOURCE_H


#include <cstdint>
#include <memory>
#include <android/asset_manager.h>
#include "AudioProperties.h"

class AAssetDataSource {
public:
    int64_t getSize() const { return mBufferSize; }
    AudioProperties getProperties() const { return mProperties; }
    const float* getData() const { return mBuffer.get(); }

    static AAssetDataSource* newFromCompressedAsset(
            AAssetManager &assetManager,
            const char *filename,
            AudioProperties targetProperties);

private:
    AAssetDataSource(std::unique_ptr<float[]> data, size_t size,
                     const AudioProperties properties)
            : mBuffer(std::move(data))
            , mBufferSize(size)
            , mProperties(properties) {
    }

    const std::unique_ptr<float[]> mBuffer;
    const int64_t mBufferSize;
    const AudioProperties mProperties;

};


#endif //ANDROID_AASSETDATASOURCE_H
