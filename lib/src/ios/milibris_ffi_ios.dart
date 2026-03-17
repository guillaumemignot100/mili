import 'package:flutter/services.dart';
import 'package:milibris_ffi/src/ios/milibiris_ffi_service_ios.dart';

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
}
