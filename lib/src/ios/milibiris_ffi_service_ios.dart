import 'package:milibris_ffi/src/ios/milibris_ffi_ffi.dart';

/// Exception thrown by archive operations.
class MlArchiveException implements Exception {
  /// Creates a new [MlArchiveException].
  MlArchiveException({required this.message});

  /// The error message.
  final String message;

  @override
  String toString() => 'MlArchiveException: $message';
}

/// Service for iOS archive extraction operations.
/// Contains business logic and orchestration.
/// Uses [MlArchiveFfi] for native interop.
class MlArchiveServiceIos {
  const MlArchiveServiceIos();

  /// Extracts the archive at [archivePath] into [destPath].
  ///
  /// Throws [MlArchiveException] on failure.
  void extractArchive({required String archivePath, required String destPath}) {
    try {
      MlArchiveFfi.extractArchive(archivePath: archivePath, destPath: destPath);
    } on FfiArchiveError catch (e) {
      throw MlArchiveException(message: e.message);
    }
  }
}
