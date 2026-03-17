import 'dart:io';

import 'package:ffigen/ffigen.dart';

void main() {
  final sdkPath = Process.runSync('xcrun', [
    '--sdk',
    'iphoneos',
    '--show-sdk-path',
  ]).stdout.toString().trim();

  final home = Platform.environment['HOME']!;
  final findResult = Process.runSync('find', [
    '$home/Library/Developer/Xcode/DerivedData',
    '-name',
    'MiLibrisReaderSDK.h',
    '-path',
    '*/ios-arm64/MiLibrisReaderSDK.framework/Headers/*',
  ]);
  final miliHeader = findResult.stdout
      .toString()
      .trim()
      .split('\n')
      .firstOrNull;
  if (miliHeader == null || miliHeader.isEmpty) {
    throw StateError(
      'MiLibrisReaderSDK.h not found in DerivedData. '
      'Open the example app in Xcode and build it once to download the SPM package.',
    );
  }

  final generator = FfiGenerator(
    output: Output(
      dartFile: Uri.parse('lib/src/ios/milibris_ffi_bindings.g.dart'),
      style: const NativeExternalBindings(
        assetId: 'package:milibris_ffi/milibris_ffi.dylib',
      ),
    ),
    headers: Headers(entryPoints: [Uri.file(miliHeader)]),
    objectiveC: ObjectiveC(interfaces: Interfaces.includeSet({'MLArchive'})),
  );

  generator.generate();
}
