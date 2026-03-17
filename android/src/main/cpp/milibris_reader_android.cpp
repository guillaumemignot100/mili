#include "milibris_reader.h"

#include <android/log.h>
#include <jni.h>
#include <string>

#define LOG_TAG "MilibrisReader"
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

static JavaVM *g_jvm = nullptr;

// Captured once when the library is loaded so JNI calls can be made from any
// thread (including the background isolate that Dart runs FFI work on).
JNIEXPORT jint JNI_OnLoad(JavaVM *vm, void * /*reserved*/) {
  g_jvm = vm;
  return JNI_VERSION_1_6;
}

// ---------------------------------------------------------------------------
// Helper: attach the calling thread to the JVM if needed.
// Returns true and sets *env on success.  Sets *did_attach so the caller
// can detach again afterwards.
// ---------------------------------------------------------------------------
static bool get_jni_env(JNIEnv **env, bool *did_attach) {
  *did_attach = false;
  if (!g_jvm)
    return false;

  jint rc = g_jvm->GetEnv(reinterpret_cast<void **>(env), JNI_VERSION_1_6);
  if (rc == JNI_OK)
    return true;
  if (rc == JNI_EDETACHED) {
    if (g_jvm->AttachCurrentThread(env, nullptr) != JNI_OK)
      return false;
    *did_attach = true;
    return true;
  }
  return false;
}

// ---------------------------------------------------------------------------
// milibris_extract_archive
//
// Calls the Android MiLibris SDK equivalent of MLArchive.extract().
//
// TODO: Confirm the exact class name and method signature from the Android
//       MiLibris Reader SDK (AAR).  The stub below assumes:
//         class  : com.milibris.reader.sdk.MLArchive
//         method : static void extract(String archivePath, String destPath)
//                  throws Exception
// ---------------------------------------------------------------------------
FFI_PLUGIN_EXPORT int32_t milibris_extract_archive(const char *archive_path,
                                                   const char *dest_path) {
  if (!archive_path || !dest_path)
    return -1;

  JNIEnv *env = nullptr;
  bool did_attach = false;
  if (!get_jni_env(&env, &did_attach))
    return -2;

  int32_t result = 0;

  jclass cls = env->FindClass("com/milibris/reader/sdk/MLArchive");
  if (!cls) {
    LOGE("Class com/milibris/reader/sdk/MLArchive not found");
    env->ExceptionClear();
    result = -3;
    goto cleanup;
  }

  {
    jmethodID mid = env->GetStaticMethodID(
        cls, "extract", "(Ljava/lang/String;Ljava/lang/String;)V");
    if (!mid) {
      LOGE("Method MLArchive.extract(String, String) not found");
      env->ExceptionClear();
      result = -4;
      goto cleanup;
    }

    jstring j_archive = env->NewStringUTF(archive_path);
    jstring j_dest = env->NewStringUTF(dest_path);

    env->CallStaticVoidMethod(cls, mid, j_archive, j_dest);

    env->DeleteLocalRef(j_archive);
    env->DeleteLocalRef(j_dest);

    if (env->ExceptionCheck()) {
      LOGE("Exception during MLArchive.extract");
      env->ExceptionDescribe();
      env->ExceptionClear();
      result = -5;
    }
  }

cleanup:
  if (cls)
    env->DeleteLocalRef(cls);
  if (did_attach)
    g_jvm->DetachCurrentThread();
  return result;
}
