import 'package:jni/jni.dart';
import 'package:milibris_ffi/src/android/milibris_ffi_bindings.g.dart';

/// Raw error from native Android APIs.
class JniNativeError {
  /// Creates a new [JniNativeError].
  JniNativeError({this.details});

  /// Error details from the native exception.
  final String? details;
}

/// Pure JNI wrapper around the Milibris Foundation API.
/// Only handles type conversions and native calls.
/// No business logic, no error messages, no orchestration.
class MilibrisFFIJni {
  FoundationContext _buildContext() {
    final ctx = Foundation.createContext(Jni.androidApplicationContext);
    if (ctx == null)
      throw JniNativeError(details: 'createContext returned null');
    return ctx;
  }

  /// Creates a [CompleteArchive] from a file path string, then unpacks it to
  /// [destinationPath]. Returns the unpacked [JObject] (Release) on success,
  /// throws [JniNativeError] on failure.
  JObject unpackArchive({
    required String archivePath,
    required String destinationPath,
  }) {
    try {
      final archive = CompleteArchive.new$3(
        _buildContext(),
        archivePath.toJString(),
      );
      final release = archive.unpackTo$1(destinationPath.toJString());
      if (release == null) {
        throw JniNativeError(details: 'unpackTo returned null');
      }
      return release;
    } on JniNativeError {
      rethrow;
    } catch (e) {
      throw JniNativeError(details: e.toString());
    }
  }

  /// Creates a [CompleteArchive] from an Android [Uri], then unpacks it to
  /// [destinationPath]. Returns the unpacked [JObject] (Release) on success,
  /// throws [JniNativeError] on failure.
  JObject unpackArchiveFromUri({
    required JObject uri,
    required String destinationPath,
  }) {
    try {
      final archive = CompleteArchive.new$1(_buildContext(), uri);
      final release = archive.unpackTo$1(destinationPath.toJString());
      if (release == null) {
        throw JniNativeError(details: 'unpackTo returned null');
      }
      return release;
    } on JniNativeError {
      rethrow;
    } catch (e) {
      throw JniNativeError(details: e.toString());
    }
  }

  /// Creates a [CompleteArchive] from a [java.io.File], then unpacks it to
  /// a destination [java.io.File]. Returns the unpacked [JObject] (Release)
  /// on success, throws [JniNativeError] on failure.
  JObject unpackArchiveFromFile({
    required JObject file,
    required JObject destinationFile,
  }) {
    try {
      final archive = CompleteArchive.new$2(_buildContext(), file);
      final release = archive.unpackTo(destinationFile);
      if (release == null) {
        throw JniNativeError(details: 'unpackTo returned null');
      }
      return release;
    } on JniNativeError {
      rethrow;
    } catch (e) {
      throw JniNativeError(details: e.toString());
    }
  }
}
