//
// Created by Sebastian Lisiecki on 27/01/2022.
//

#ifndef ANDROID_NDKEXTRACTOR_H
#define ANDROID_NDKEXTRACTOR_H


#include <cstdint>
#include <android/asset_manager.h>
#include "AudioProperties.h"

class NDKExtractor {
public:
    static int32_t decode(AAsset *asset, uint8_t *targetData, AudioProperties targetProperties);
};


#endif //ANDROID_NDKEXTRACTOR_H
