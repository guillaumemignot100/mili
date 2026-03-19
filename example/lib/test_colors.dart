// ignore_for_file: public_member_api_docs

/// Shared ARGB color constants for the test customization.
///
/// Used by both [_testCustomization] in `main.dart` (via `dart:ui` Color) and
/// `tool/generate_android_colors.dart` (as raw ints), so they always stay in
/// sync. Edit here; both consumers pick up the change automatically.
library;

// NavBar
const int kNavBarBackgroundLight = 0xFFFF007F; // hot pink
const int kNavBarBackgroundDark  = 0xFF7F00FF; // purple
const int kNavBarButtonsTint     = 0xFFFFFF00; // yellow (unified)
const int kNavBarTitleTextLight  = 0xFF00FF00; // lime green
const int kNavBarTitleTextDark   = 0xFFFF6600; // orange
const int kNavBarSubtitleText    = 0xFF00FFFF; // cyan (unified)
const int kNavBarProgressBg      = 0xFFFF0000; // red (unified)
const int kNavBarProgressFill    = 0xFF00FF00; // green (unified)
const int kNavBarLogoCapLight    = 0xFFFFFF00; // yellow
const int kNavBarLogoCapDark     = 0xFF0000FF; // blue

// Reader
const int kReaderBackground      = 0xFFFFF9C4; // pale yellow (unified)

// MiniSummary
const int kMiniSummaryCellTitle  = 0xFFE91E63; // pink (unified)
const int kMiniSummarySeparator  = 0xFF3F51B5; // indigo (unified)
