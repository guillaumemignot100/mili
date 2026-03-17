import 'package:flutter/services.dart';
import 'package:jni/jni.dart';
import 'package:milibris_ffi/src/android/milibris_ffi_service_android.dart';

/// Android implementation of Milibris FFI operations.
/// Wraps [MilibrisFFIServiceAndroid] and converts [MilibrisFFIException]
/// to [PlatformException].
class MilibrisFFIAndroid {
  final MilibrisFFIServiceAndroid _service = MilibrisFFIServiceAndroid();

  /// Unpacks an archive from a file path to [destinationPath].
  ///
  /// Returns the unpacked [JObject] (Release) on success.
  /// Throws [PlatformException] on failure.
  JObject unpackArchive({
    required String archivePath,
    required String destinationPath,
  }) {
    try {
      return _service.unpackArchive(
        archivePath: archivePath,
        destinationPath: destinationPath,
      );
    } on MilibrisFFIException catch (e) {
      throw PlatformException(
        code: e.code.name,
        message: e.message,
        details: e.details,
      );
    }
  }

  /// Unpacks an archive from an Android [Uri] to [destinationPath].
  ///
  /// Returns the unpacked [JObject] (Release) on success.
  /// Throws [PlatformException] on failure.
  JObject unpackArchiveFromUri({
    required JObject uri,
    required String destinationPath,
  }) {
    try {
      return _service.unpackArchiveFromUri(
        uri: uri,
        destinationPath: destinationPath,
      );
    } on MilibrisFFIException catch (e) {
      throw PlatformException(
        code: e.code.name,
        message: e.message,
        details: e.details,
      );
    }
  }

  /// Unpacks an archive from a [java.io.File] to a destination [java.io.File].
  ///
  /// Returns the unpacked [JObject] (Release) on success.
  /// Throws [PlatformException] on failure.
  JObject unpackArchiveFromFile({
    required JObject file,
    required JObject destinationFile,
  }) {
    try {
      return _service.unpackArchiveFromFile(
        file: file,
        destinationFile: destinationFile,
      );
    } on MilibrisFFIException catch (e) {
      throw PlatformException(
        code: e.code.name,
        message: e.message,
        details: e.details,
      );
    }
  }
}
