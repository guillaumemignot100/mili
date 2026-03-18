// ignore_for_file: invalid_use_of_internal_member, type=lint
import 'package:jni/_internal.dart' as jni$;
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

  // Raw JNI for Android framework calls not covered by generated bindings.
  static final _intentClass = JClass.forName('android/content/Intent');
  static final _contextClass = JClass.forName('android/content/Context');

  static final _idAddFlags = _intentClass.instanceMethodId(
    r'addFlags',
    r'(I)Landroid/content/Intent;',
  );
  static final _idStartActivity = _contextClass.instanceMethodId(
    r'startActivity',
    r'(Landroid/content/Intent;)V',
  );

  static final _callObjectInt1 = jni$.ProtectedJniExtensions.lookup<
    jni$.NativeFunction<
      jni$.JniResult Function(
        jni$.Pointer<jni$.Void>,
        jni$.JMethodIDPtr,
        jni$.VarArgs<(jni$.Int32,)>,
      )
    >
  >('globalEnv_CallObjectMethod').asFunction<
    jni$.JniResult Function(
      jni$.Pointer<jni$.Void>,
      jni$.JMethodIDPtr,
      int,
    )
  >();

  static final _callVoid1 = jni$.ProtectedJniExtensions.lookup<
    jni$.NativeFunction<
      jni$.JThrowablePtr Function(
        jni$.Pointer<jni$.Void>,
        jni$.JMethodIDPtr,
        jni$.VarArgs<(jni$.Pointer<jni$.Void>,)>,
      )
    >
  >('globalEnv_CallVoidMethod').asFunction<
    jni$.JThrowablePtr Function(
      jni$.Pointer<jni$.Void>,
      jni$.JMethodIDPtr,
      jni$.Pointer<jni$.Void>,
    )
  >();

  /// Launches [OneReaderActivity] for the unpacked release at [contentPath].
  /// Throws [JniNativeError] on failure.
  void openReader({required String contentPath}) {
    try {
      final ctx = Jni.androidApplicationContext;
      final settings = ReaderSettings.new$2();
      final dataSource = XmlPdfReaderDataSource(settings, null);
      dataSource.init(ctx, contentPath.toJString());

      final intent = OneReaderActivity.newIntent(
        ctx,
        settings,
        dataSource, // implements ProductRepository
        null, // readerListener
        null, // pageAdRepository
        null, // searchProvider
        null, // logger
        null, // sharedElementImageUrl
        null, // sharedElementRatio
      );

      // FLAG_ACTIVITY_NEW_TASK required when launching from application context.
      _callObjectInt1(
        intent.reference.pointer,
        _idAddFlags as jni$.JMethodIDPtr,
        0x10000000,
      ).object(JObject.type).release();

      _callVoid1(
        ctx.reference.pointer,
        _idStartActivity as jni$.JMethodIDPtr,
        intent.reference.pointer,
      ).check();

      settings.release();
      dataSource.release();
      intent.release();
    } on JniNativeError {
      rethrow;
    } catch (e) {
      throw JniNativeError(details: e.toString());
    }
  }
}
