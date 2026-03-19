import 'package:flutter/services.dart';
import 'package:milibris_ffi/src/ios/milibiris_ffi_service_ios.dart';
import 'package:milibris_ffi/src/reader_customization.dart';

/// iOS implementation of Milibris FFI operations.
/// Wraps [MlArchiveServiceIos] and converts [MlArchiveException]
/// to [PlatformException].
class MilibrisFFIIos {
  final MlArchiveServiceIos _service = const MlArchiveServiceIos();

  /// Extracts the archive at [archivePath] into [destPath].
  ///
  /// Throws [PlatformException] on failure.
  void extractArchive({required String archivePath, required String destPath}) {
    try {
      _service.extractArchive(archivePath: archivePath, destPath: destPath);
    } on MlArchiveException catch (e) {
      throw PlatformException(code: 'extraction_failed', message: e.message);
    }
  }

  /// Opens the reader for the release at [releasePath].
  ///
  /// [languageCode] is optional (e.g. `'frFR'`).
  /// [customization] is optional visual/feature configuration.
  void openReader({
    required String releasePath,
    String languageCode = '',
    ReaderCustomization? customization,
  }) {
    _service.openReader(
      releasePath: releasePath,
      languageCode: languageCode,
      customization: customization,
    );
  }
}
