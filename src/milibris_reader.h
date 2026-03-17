#ifndef MILIBRIS_READER_H
#define MILIBRIS_READER_H

#include <stdint.h>

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

#ifdef __cplusplus
extern "C" {
#endif

// Extracts a Milibris .complete archive to the destination directory.
// archive_path: absolute path to the .complete archive file.
// dest_path:    absolute path to the directory where the archive is extracted.
// Returns 0 on success, negative error code on failure.
FFI_PLUGIN_EXPORT int32_t milibris_extract_archive(
    const char* archive_path,
    const char* dest_path);

#ifdef __cplusplus
}
#endif

#endif  // MILIBRIS_READER_H
