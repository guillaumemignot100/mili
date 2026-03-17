import 'package:jni/jni.dart';
import 'package:milibris_ffi/src/android/milibris_ffi_jni.dart';

/// Error codes for Milibris FFI operations.
enum MilibrisFFIErrorCode {
  /// Failed to unpack the archive.
  unpackFailed,
}

/// Exception thrown by Milibris FFI operations.
class MilibrisFFIException implements Exception {
  /// Creates a new [MilibrisFFIException].
  MilibrisFFIException({
    required this.code,
    required this.message,
    this.details,
  });

  /// The error code.
  final MilibrisFFIErrorCode code;

  /// The error message.
  final String message;

  /// Additional error details, if available.
  final String? details;

  @override
  String toString() => 'MilibrisFFIException: $message';
}

/// Service for Android Milibris FFI operations.
/// Contains business logic and orchestration.
/// Uses [MilibrisFFIJni] for native interop.
class MilibrisFFIServiceAndroid {
  /// Creates a new [MilibrisFFIServiceAndroid].
  /// Optionally accepts a [MilibrisFFIJni] for testing.
  MilibrisFFIServiceAndroid({MilibrisFFIJni? jni})
    : _jni = jni ?? MilibrisFFIJni();

  final MilibrisFFIJni _jni;

  /// Unpacks an archive from a file path to [destinationPath].
  ///
  /// Returns the unpacked [JObject] (Release) on success.
  /// Throws [MilibrisFFIException] on failure.
  JObject unpackArchive({
    required String archivePath,
    required String destinationPath,
  }) {
    try {
      return _jni.unpackArchive(
        archivePath: archivePath,
        destinationPath: destinationPath,
      );
    } on JniNativeError catch (e) {
      throw MilibrisFFIException(
        code: .unpackFailed,
        message: 'Failed to unpack archive',
        details: e.details,
      );
    }
  }

  /// Unpacks an archive from an Android [Uri] to [destinationPath].
  ///
  /// Returns the unpacked [JObject] (Release) on success.
  /// Throws [MilibrisFFIException] on failure.
  JObject unpackArchiveFromUri({
    required JObject uri,
    required String destinationPath,
  }) {
    try {
      return _jni.unpackArchiveFromUri(
        uri: uri,
        destinationPath: destinationPath,
      );
    } on JniNativeError catch (e) {
      throw MilibrisFFIException(
        code: .unpackFailed,
        message: 'Failed to unpack archive from URI',
        details: e.details,
      );
    }
  }

  /// Unpacks an archive from a [java.io.File] to a destination [java.io.File].
  ///
  /// Returns the unpacked [JObject] (Release) on success.
  /// Throws [MilibrisFFIException] on failure.
  JObject unpackArchiveFromFile({
    required JObject file,
    required JObject destinationFile,
  }) {
    try {
      return _jni.unpackArchiveFromFile(
        file: file,
        destinationFile: destinationFile,
      );
    } on JniNativeError catch (e) {
      throw MilibrisFFIException(
        code: .unpackFailed,
        message: 'Failed to unpack archive from file',
        details: e.details,
      );
    }
  }
}
