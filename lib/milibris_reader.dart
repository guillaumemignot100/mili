import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:native_add/milibris_reader_bindings_generated.dart';

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Extracts a Milibris `.complete` archive into [destPath].
///
/// This wraps `MLArchive.extract(archiveURL, inDirectory:)` on iOS and the
/// equivalent Android SDK call.
///
/// Throws [MilibrisExtractException] on failure.
void extractArchive({required String archivePath, required String destPath}) {
  final code = _bindings.milibris_extract_archive(
    archivePath.toNativeUtf8().cast<Char>(),
    destPath.toNativeUtf8().cast<Char>(),
  );
  if (code != 0) throw MilibrisExtractException(code);
}

const String _libName = 'milibris_reader';

DynamicLibrary _openDylib() {
  if (Platform.isIOS) {
    return DynamicLibrary.process();
  }
  if (Platform.isMacOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}

/// The dynamic library in which the symbols for [MilibrisReaderBindings]
/// can be found.
final DynamicLibrary _dylib = _openDylib();

/// The bindings to the native functions in [_dylib].
final MilibrisReaderBindings _bindings = MilibrisReaderBindings(_dylib);

/// Thrown when [extractArchive] fails.
///
/// [code] maps to the native return value:
///  -1 : null argument
///  -2 : JVM not available (Android) / MLArchive.extract threw (iOS)
///  -3 : MLArchive class not found (Android only)
///  -4 : extract method not found (Android only)
///  -5 : extraction threw a Java exception (Android only)
class MilibrisExtractException implements Exception {
  const MilibrisExtractException(this.code);

  final int code;

  @override
  String toString() => 'MilibrisExtractException(code: $code)';
}
