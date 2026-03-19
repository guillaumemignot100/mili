import 'dart:convert';
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as pkg_ffi;
import 'package:milibris_ffi/src/ios/milibris_ffi_bindings.g.dart';
import 'package:milibris_ffi/src/reader_customization.dart';
import 'package:objective_c/objective_c.dart' as objc;

/// Raw error from [MlArchiveFfi.extractArchive].
class FfiArchiveError implements Exception {
  /// Creates a [FfiArchiveError].
  const FfiArchiveError({required this.message});

  /// The error message.
  final String message;

  @override
  String toString() => 'FfiArchiveError: $message';
}

final _openReaderFn = ffi.DynamicLibrary.process().lookupFunction<
  ffi.Void Function(
    ffi.Pointer<pkg_ffi.Utf8>,
    ffi.Pointer<pkg_ffi.Utf8>,
    ffi.Pointer<pkg_ffi.Utf8>,
  ),
  void Function(
    ffi.Pointer<pkg_ffi.Utf8>,
    ffi.Pointer<pkg_ffi.Utf8>,
    ffi.Pointer<pkg_ffi.Utf8>,
  )
>('milibris_open_reader');

/// Pure FFI wrapper around the MiLibrisReaderSDK Reader API.
abstract final class MlReaderFfi {
  /// Opens the reader for the release at [releasePath].
  ///
  /// [languageCode] is optional (e.g. `'frFR'`). Pass empty string to use the
  /// SDK default.
  /// [customization] is optional visual/feature configuration.
  static void openReader({
    required String releasePath,
    String languageCode = '',
    ReaderCustomization? customization,
  }) {
    final releasePathPtr = releasePath.toNativeUtf8();
    final languageCodePtr = languageCode.toNativeUtf8();
    final configJsonPtr = _serializeCustomization(customization).toNativeUtf8();
    try {
      _openReaderFn(releasePathPtr, languageCodePtr, configJsonPtr);
    } finally {
      pkg_ffi.calloc.free(releasePathPtr);
      pkg_ffi.calloc.free(languageCodePtr);
      pkg_ffi.calloc.free(configJsonPtr);
    }
  }

  static String _serializeCustomization(ReaderCustomization? c) {
    if (c == null) return '{}';
    return jsonEncode({
      if (c.navBar case final navBar?) 'navBar': _encodeNavBar(navBar),
      if (c.reader case final reader?) 'reader': _encodeReader(reader),
      if (c.miniSummary case final ms?) 'miniSummary': _encodeMiniSummary(ms),
    });
  }

  static Map<String, dynamic> _encodeNavBar(NavBarCustomization n) => {
    'background': ?_encodeColor(n.backgroundColor),
    'buttonsTint': ?_encodeColor(n.buttonsTintColor),
    'titleText': ?_encodeColor(n.titleTextColor),
    'titleFont': ?n.titleFontName,
    'subtitleText': ?_encodeColor(n.subtitleTextColor),
    'subtitleFont': ?n.subtitleFontName,
    'progressbarBackground': ?_encodeColor(n.progressbarBackgroundColor),
    'progressbarFill': ?_encodeColor(n.progressbarFillColor),
    'logoBackground': ?_encodeColor(n.logoBackgroundColor),
  };

  static Map<String, dynamic> _encodeReader(ReaderViewCustomization r) => {
    'background': ?_encodeColor(r.backgroundColor),
    'isDoublePagesEnabled': ?r.isDoublePagesEnabled,
    'isSummaryEnabled': ?r.isSummaryEnabled,
  };

  static Map<String, dynamic> _encodeMiniSummary(
    MiniSummaryCustomization m,
  ) => {
    'cellTitleText': ?_encodeColor(m.cellTitleTextColor),
    'separator': ?_encodeColor(m.separatorColor),
  };

  /// Encodes a [ReaderColor] as `{"light": argb, "dark": argb}`.
  /// Returns null when [color] is null (allows null-aware map entry `?`).
  static Map<String, int>? _encodeColor(ReaderColor? color) {
    if (color == null) return null;
    return {
      'light': color.light.toARGB32(),
      'dark': ?color.dark?.toARGB32(),
    };
  }
}

/// Pure FFI wrapper around the MLArchive ObjC API.
abstract final class MlArchiveFfi {
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
      final success = MLArchive.extract(
        archiveUrl,
        inDirectory: destUrl,
        error: errorPtr,
      );

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
