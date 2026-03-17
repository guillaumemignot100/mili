import 'package:jni/jni.dart';

import 'src/android/milibris_ffi_android.dart';

/// Entry point for Milibris FFI operations on Android.
class MilibrisFFI {
  /// Creates a new [MilibrisFFI].
  MilibrisFFI();

  final _android = MilibrisFFIAndroid();

  /// Unpacks an archive from a file path to [destinationPath].
  ///
  /// Returns the unpacked [JObject] (Release) on success.
  /// Throws [PlatformException] on failure.
  JObject unpackArchive({
    required String archivePath,
    required String destinationPath,
  }) {
    return _android.unpackArchive(
      archivePath: archivePath,
      destinationPath: destinationPath,
    );
  }

  /// Unpacks an archive from an Android [Uri] to [destinationPath].
  ///
  /// Returns the unpacked [JObject] (Release) on success.
  /// Throws [PlatformException] on failure.
  JObject unpackArchiveFromUri({
    required JObject uri,
    required String destinationPath,
  }) {
    return _android.unpackArchiveFromUri(
      uri: uri,
      destinationPath: destinationPath,
    );
  }

  /// Unpacks an archive from a [java.io.File] to a destination [java.io.File].
  ///
  /// Returns the unpacked [JObject] (Release) on success.
  /// Throws [PlatformException] on failure.
  JObject unpackArchiveFromFile({
    required JObject file,
    required JObject destinationFile,
  }) {
    return _android.unpackArchiveFromFile(
      file: file,
      destinationFile: destinationFile,
    );
  }
}
