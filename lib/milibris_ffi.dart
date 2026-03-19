import 'dart:io';

import 'package:jni/jni.dart';
import 'package:milibris_ffi/src/android/milibris_ffi_android.dart';
import 'package:milibris_ffi/src/ios/milibris_ffi_ios.dart';
import 'package:milibris_ffi/src/reader_customization.dart';

export 'package:milibris_ffi/src/reader_customization.dart';

/// Entry point for Milibris FFI operations.
class MilibrisFFI {
  /// Creates a new [MilibrisFFI].
  MilibrisFFI();

  final _android = MilibrisFFIAndroid();
  final _ios = MilibrisFFIIos();

  /// Extracts an archive at [archivePath] into [destPath].
  ///
  /// On iOS, uses the native C FFI. Throws [PlatformException] on failure.
  /// On other platforms, throws [UnsupportedError].
  void extractArchive({required String archivePath, required String destPath}) {
    if (Platform.isIOS) {
      _ios.extractArchive(archivePath: archivePath, destPath: destPath);
    } else {
      throw UnsupportedError('extractArchive is only supported on iOS.');
    }
  }

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

  /// Launches the reader for the unpacked release at [contentPath].
  ///
  /// On Android, uses JNI to start [OneReaderActivity].
  /// On iOS, uses FFI to call the native Swift bridge.
  /// [languageCode] is iOS-only and optional (e.g. `'frFR'`).
  /// Throws [PlatformException] on failure.
  void openReader({
    required String contentPath,
    String languageCode = '',
    ReaderCustomization? customization,
  }) {
    if (Platform.isAndroid) {
      _android.openReader(
        contentPath: contentPath,
        customization: customization,
      );
    } else if (Platform.isIOS) {
      _ios.openReader(
        releasePath: contentPath,
        languageCode: languageCode,
        customization: customization,
      );
    } else {
      throw UnsupportedError(
        'openReader is only supported on Android and iOS.',
      );
    }
  }
}
