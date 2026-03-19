// ignore_for_file: avoid_print, dangling_library_doc_comments,
//   avoid_relative_lib_imports

/// Generates Android color resources from the reader customization.
///
/// Color values are read from `example/lib/test_colors.dart` — the same
/// source used by `_testCustomization` in `example/lib/main.dart`.
/// Edit `test_colors.dart`, then run:
///
///   dart run tool/generate_android_colors.dart
///
/// This overwrites:
///   example/android/app/src/main/res/values/colors.xml
///   example/android/app/src/main/res/values/styles.xml  (styles block only)

import 'dart:io';

import '../example/lib/test_colors.dart';

// ─── Mapping from shared constants to Android resource fields ────────────────

const _config = _AndroidColors(
  // NavBar
  navBarBackgroundLight:     kNavBarBackgroundLight,
  navBarBackgroundDark:      kNavBarBackgroundDark,
  navBarButtonsTintLight:    kNavBarButtonsTint,
  navBarButtonsTintDark:     kNavBarButtonsTint,
  navBarTitleTextLight:      kNavBarTitleTextLight,
  navBarTitleTextDark:       kNavBarTitleTextDark,
  navBarSubtitleTextLight:   kNavBarSubtitleText,
  navBarSubtitleTextDark:    kNavBarSubtitleText,
  navBarProgressBackground:  kNavBarProgressBg,
  navBarProgressFill:        kNavBarProgressFill,
  navBarLogoCapsuleLight:    kNavBarLogoCapLight,
  navBarLogoCapsuleDark:     kNavBarLogoCapDark,
  // Reader
  readerBackground:          kReaderBackground,
  // MiniSummary
  miniSummaryCellTitleText:  kMiniSummaryCellTitle,
  miniSummarySeparatorLight: kMiniSummarySeparator,
  miniSummarySeparatorDark:  kMiniSummarySeparator,
);

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  final root = _repoRoot();
  _writeColorsXml(root);
  _patchStylesXml(root);
  print('Done.');
}

// ── colors.xml ───────────────────────────────────────────────────────────────

void _writeColorsXml(String root) {
  final path =
      '$root/example/android/app/src/main/res/values/colors.xml';
  File(path).writeAsStringSync(_colorsXml(_config));
  print('Wrote $path');
}

String _colorsXml(_AndroidColors c) => '''
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- NavBar: backgroundColor -->
    <color name="or_toolbar_background_color_light">${_hex(c.navBarBackgroundLight)}</color>
    <color name="or_toolbar_background_color_dark">${_hex(c.navBarBackgroundDark)}</color>

    <!-- NavBar: buttonsTintColor -->
    <color name="or_navigation_button_tint_light">${_hex(c.navBarButtonsTintLight)}</color>
    <color name="or_navigation_button_tint_dark">${_hex(c.navBarButtonsTintDark)}</color>

    <!-- NavBar: titleTextColor -->
    <color name="or_toolbar_title_text_light">${_hex(c.navBarTitleTextLight)}</color>
    <color name="or_toolbar_title_text_dark">${_hex(c.navBarTitleTextDark)}</color>

    <!-- NavBar: subtitleTextColor -->
    <color name="or_toolbar_subtitle_text_light">${_hex(c.navBarSubtitleTextLight)}</color>
    <color name="or_toolbar_subtitle_text_dark">${_hex(c.navBarSubtitleTextDark)}</color>

    <!-- NavBar: progressbarBackgroundColor -->
    <color name="or_progress_background_color">${_hex(c.navBarProgressBackground)}</color>

    <!-- NavBar: progressbarFillColor -->
    <color name="or_progress_color">${_hex(c.navBarProgressFill)}</color>

    <!-- NavBar: logoBackgroundColor -->
    <color name="or_logo_capsule_color_light">${_hex(c.navBarLogoCapsuleLight)}</color>
    <color name="or_logo_capsule_color_dark">${_hex(c.navBarLogoCapsuleDark)}</color>

    <!-- Reader: backgroundColor -->
    <color name="or_background_color">${_hex(c.readerBackground)}</color>

    <!-- MiniSummary: separatorColor -->
    <color name="or_mini_summary_separator_light">${_hex(c.miniSummarySeparatorLight)}</color>
    <color name="or_mini_summary_separator_dark">${_hex(c.miniSummarySeparatorDark)}</color>
</resources>
'''.trimLeft();

// ── styles.xml ───────────────────────────────────────────────────────────────

const _markerStart = '    <!-- [generated] MiniSummary -->';
const _markerEnd = '    <!-- [/generated] MiniSummary -->';

void _patchStylesXml(String root) {
  final path =
      '$root/example/android/app/src/main/res/values/styles.xml';
  final file = File(path);
  var src = file.readAsStringSync();

  final block = '''
$_markerStart
    <!-- MiniSummary: cellTitleTextColor -->
    <style name="OneReaderFlatPlanArticleTitleTextView">
        <item name="android:textColor">${_hex(_config.miniSummaryCellTitleText)}</item>
    </style>
$_markerEnd'''
      .trimLeft();

  if (src.contains(_markerStart)) {
    final start = src.indexOf(_markerStart);
    final end = src.indexOf(_markerEnd) + _markerEnd.length;
    src = src.replaceRange(start, end, block);
  } else {
    src = src.replaceFirst('</resources>', '$block\n</resources>');
  }

  file.writeAsStringSync(src);
  print('Patched $path');
}

// ── helpers ──────────────────────────────────────────────────────────────────

/// Converts a Flutter ARGB int (0xAARRGGBB) to an Android hex color string.
String _hex(int argb) {
  final a = (argb >> 24) & 0xFF;
  final r = (argb >> 16) & 0xFF;
  final g = (argb >> 8) & 0xFF;
  final b = argb & 0xFF;
  String h(int v) => v.toRadixString(16).padLeft(2, '0').toUpperCase();
  return a == 0xFF ? '#${h(r)}${h(g)}${h(b)}' : '#${h(a)}${h(r)}${h(g)}${h(b)}';
}

String _repoRoot() {
  var dir = File(Platform.script.toFilePath()).parent;
  while (!File('${dir.path}/pubspec.yaml').existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) throw StateError('pubspec.yaml not found');
    dir = parent;
  }
  return dir.path;
}

// ── data class ───────────────────────────────────────────────────────────────

class _AndroidColors {
  const _AndroidColors({
    required this.navBarBackgroundLight,
    required this.navBarBackgroundDark,
    required this.navBarButtonsTintLight,
    required this.navBarButtonsTintDark,
    required this.navBarTitleTextLight,
    required this.navBarTitleTextDark,
    required this.navBarSubtitleTextLight,
    required this.navBarSubtitleTextDark,
    required this.navBarProgressBackground,
    required this.navBarProgressFill,
    required this.navBarLogoCapsuleLight,
    required this.navBarLogoCapsuleDark,
    required this.readerBackground,
    required this.miniSummaryCellTitleText,
    required this.miniSummarySeparatorLight,
    required this.miniSummarySeparatorDark,
  });

  final int navBarBackgroundLight;
  final int navBarBackgroundDark;
  final int navBarButtonsTintLight;
  final int navBarButtonsTintDark;
  final int navBarTitleTextLight;
  final int navBarTitleTextDark;
  final int navBarSubtitleTextLight;
  final int navBarSubtitleTextDark;
  final int navBarProgressBackground;
  final int navBarProgressFill;
  final int navBarLogoCapsuleLight;
  final int navBarLogoCapsuleDark;
  final int readerBackground;
  final int miniSummaryCellTitleText;
  final int miniSummarySeparatorLight;
  final int miniSummarySeparatorDark;
}
