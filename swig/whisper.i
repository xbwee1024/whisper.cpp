%module Whisper 
%{
#include "whisper.h"
#ifdef WHISPER_LOGCAT
#include <android/log.h>
void android_log(enum ggml_log_level level, const char * text, void * user_data) {
    android_LogPriority android_level = ANDROID_LOG_INFO;
    switch (level) {
        case GGML_LOG_LEVEL_DEBUG: android_level = ANDROID_LOG_DEBUG; break;
        case GGML_LOG_LEVEL_INFO: android_level = ANDROID_LOG_INFO; break;
        case GGML_LOG_LEVEL_WARN: android_level = ANDROID_LOG_WARN; break;
        case GGML_LOG_LEVEL_ERROR: android_level = ANDROID_LOG_ERROR; break;
    }
    __android_log_print(android_level, "Whisper", "%s", text);
}
#endif
%}
%include "stdint.i"
%include "cpointer.i"
%include "carrays.i"
%include "typemaps.i"

%array_class(float, FloatArray);
%array_class(int, IntArray);
%array_class(char, ByteArray);

%rename("%(camelcase)s", %$isclass) "";
%rename("%(camelcase)s", %$isenum) "";
%rename("%(lowercamelcase)s", %$isfunction) "";
%rename("%(lowercamelcase)s", %$isvariable) "";
%rename("%(strip:[whisper]s", %$isfunction) "";
%apply unsigned int { enum ggml_log_level };
%typedef void (*ggml_log_callback)(enum ggml_log_level level, const char * text, void * user_data);
%callback("%s_cb");
void android_log(enum ggml_log_level level, const char* text, void* user_data);
%nocallback;

%include "whisper.h"
