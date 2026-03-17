import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:milibris_ffi/milibris_ffi.dart';

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
      final destPath = Directory.systemTemp.path;

      final release = _ffi.unpackArchive(
        archivePath:
            '/sdcard/Download/fc7558b2-3baf-46d5-82b1-7287a44cd269.complete',
        destinationPath: destPath,
      );

      setState(() => _status = 'Bridge OK. Result: $release');
    } on PlatformException catch (e) {
      setState(
        () =>
            _status = 'Bridge reached native. Error [${e.code}]: ${e.message}',
      );
    } catch (e) {
      setState(() => _status = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
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
