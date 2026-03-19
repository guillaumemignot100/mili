import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:milibris_ffi/milibris_ffi.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Milibris FFI Example', home: const UnpackPage());
  }
}

class UnpackPage extends StatefulWidget {
  const UnpackPage({super.key});

  @override
  State<UnpackPage> createState() => _UnpackPageState();
}

class _UnpackPageState extends State<UnpackPage> {
  final _ffi = MilibrisFFI();

  String _status = 'Idle';
  bool _loading = false;

  Future<void> _testBridge() async {
    setState(() {
      _loading = true;
      _status = 'Calling native layer…';
    });

    try {
      final destDir = Directory('${Directory.systemTemp.path}/mili_out');
      if (destDir.existsSync()) destDir.deleteSync(recursive: true);
      destDir.createSync();
      final destPath = destDir.path;

      final fileName = 'fc7558b2-3baf-46d5-82b1-7287a44cd269.complete';

      if (Platform.isAndroid) {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir == null)
          throw Exception('External storage unavailable');
        final archivePath = '${externalDir.path}/$fileName';
        _ffi.unpackArchive(archivePath: archivePath, destinationPath: destPath);
        _ffi.openReader(contentPath: destPath);
        final archiveSize = File(archivePath).lengthSync();
        final extractedSize = _dirSize(destDir);
        setState(
          () => _status =
              'Bridge OK. Reader opened.\n'
              'Archive: ${_formatBytes(archiveSize)}\n'
              'Extracted: ${_formatBytes(extractedSize)}',
        );
      } else if (Platform.isIOS) {
        final appFilesDir = await getApplicationSupportDirectory();
        final archivePath = '${appFilesDir.path}/$fileName';
        _ffi.extractArchive(archivePath: archivePath, destPath: destPath);
        _ffi.openReader(contentPath: destPath);
        final archiveSize = File(archivePath).lengthSync();
        final extractedSize = _dirSize(destDir);
        setState(
          () => _status =
              'Bridge OK. Reader opened.\n'
              'Archive: ${_formatBytes(archiveSize)}\n'
              'Extracted: ${_formatBytes(extractedSize)}',
        );
      } else {
        setState(() => _status = 'Unsupported platform.');
      }
    } on PlatformException catch (e) {
      setState(
        () => _status =
            'Bridge reached native. Error [${e.code}]: ${e.message}\nDetails: ${e.details}',
      );
    } catch (e) {
      setState(() => _status = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  int _dirSize(Directory dir) => dir
      .listSync(recursive: true)
      .whereType<File>()
      .fold(0, (s, f) => s + f.lengthSync());

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Milibris FFI')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _testBridge,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Test FFI Bridge'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Status:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(_status),
          ],
        ),
      ),
    );
  }
}
