package com.theodo.milibris_ffi

import io.flutter.embedding.engine.plugins.FlutterPlugin

/**
 * Android Flutter plugin for milibris.
 * 
 * This plugin exists to ensure the Milibris dependencies are included
 * in the app's APK. All actual functionality is implemented in Dart via JNI.
 */
class MilibrisFFIPlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }
}
