//
// Created by Sebastian Lisiecki on 27/01/2022.
//

#ifndef ANDROID_LOGUTILS_H
#define ANDROID_LOGUTILS_H

#include <stdio.h>
#include <android/log.h>
#include <vector>

#define TAG "AudioEngine"
#define  LOGV(...)  __android_log_print(ANDROID_LOG_VERBOSE,    TAG, __VA_ARGS__)
#define  LOGW(...)  __android_log_print(ANDROID_LOG_WARN,       TAG, __VA_ARGS__)
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,      TAG, __VA_ARGS__)
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO,       TAG, __VA_ARGS__)
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR,      TAG, __VA_ARGS__)

#endif //ANDROID_LOGUTILS_H
