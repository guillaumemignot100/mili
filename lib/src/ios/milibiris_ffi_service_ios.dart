import 'package:milibris_ffi/src/ios/milibris_ffi_ffi.dart';
import 'package:milibris_ffi/src/reader_customization.dart';

/// Exception thrown by archive operations.
class MlArchiveException implements Exception {
  /// Creates a new [MlArchiveException].
  const MlArchiveException({required this.message});

  /// The error message.
  final String message;

  @override
  String toString() => 'MlArchiveException: $message';
}

/// Service for iOS archive extraction operations.
/// Contains business logic and orchestration.
/// Uses [MlArchiveFfi] for native interop.
class MlArchiveServiceIos {
  /// Creates a [MlArchiveServiceIos].
  const MlArchiveServiceIos();

  /// Extracts the archive at [archivePath] into [destPath].
  ///
  /// Throws [MlArchiveException] on failure.
  void extractArchive({required String archivePath, required String destPath}) {
    try {
      MlArchiveFfi.extractArchive(archivePath: archivePath, destPath: destPath);
    } on FfiArchiveError catch (e, st) {
      Error.throwWithStackTrace(MlArchiveException(message: e.message), st);
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
    MlReaderFfi.openReader(
      releasePath: releasePath,
      languageCode: languageCode,
      customization: customization,
    );
  }
}
