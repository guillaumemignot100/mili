import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as pkg_ffi;
import 'package:milibris_ffi/src/ios/milibris_ffi_bindings.g.dart';
import 'package:objective_c/objective_c.dart' as objc;

/// Raw error from [MlArchiveFfi.extractArchive].
class FfiArchiveError {
  FfiArchiveError({required this.message});

  final String message;
}

final _openReaderFn = ffi.DynamicLibrary.process().lookupFunction<
  ffi.Void Function(ffi.Pointer<pkg_ffi.Utf8>, ffi.Pointer<pkg_ffi.Utf8>),
  void Function(ffi.Pointer<pkg_ffi.Utf8>, ffi.Pointer<pkg_ffi.Utf8>)
>('milibris_open_reader');

/// Pure FFI wrapper around the MiLibrisReaderSDK Reader API.
abstract final class MlReaderFfi {
  /// Opens the reader for the release at [releasePath].
  ///
  /// [languageCode] is optional (e.g. `'frFR'`). Pass empty string to use the
  /// SDK default.
  static void openReader({
    required String releasePath,
    String languageCode = '',
  }) {
    final releasePathPtr = releasePath.toNativeUtf8();
    final languageCodePtr = languageCode.toNativeUtf8();
    try {
      _openReaderFn(releasePathPtr, languageCodePtr);
    } finally {
      pkg_ffi.calloc.free(releasePathPtr);
      pkg_ffi.calloc.free(languageCodePtr);
    }
  }
}

/// Pure FFI wrapper around the MLArchive ObjC API.
class MlArchiveFfi {
  const MlArchiveFfi._();

  /// Extracts the archive at [archivePath] into [destPath].
  /// Throws [FfiArchiveError] on failure.
  static void extractArchive({
    required String archivePath,
    required String destPath,
  }) {
    final archiveUrl = objc.NSURL.fileURLWithPath(objc.NSString(archivePath));
    final destUrl = objc.NSURL.fileURLWithPath(objc.NSString(destPath));
    final errorPtr = pkg_ffi.calloc<ffi.Pointer<objc.ObjCObjectImpl>>();

    try {
      print('----');
      final success = MLArchive.extract(
        archiveUrl,
        inDirectory: destUrl,
        error: errorPtr,
      );
      print(success);

      if (!success) {
        var message = 'Extraction failed.';
        if (errorPtr.value.address != 0) {
          final nsError = objc.NSError.fromPointer(
            errorPtr.value,
            retain: true,
            release: true,
          );
          message = nsError.localizedDescription.toDartString();
        }
        throw FfiArchiveError(message: message);
      }
    } finally {
      pkg_ffi.calloc.free(errorPtr);
    }
  }
}
