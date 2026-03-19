# Tools

## generate_android_colors.dart

Generates Android XML color resources from the shared test customization.

### Why this exists

iOS applies reader customization at runtime via JSON (no static files needed).
Android requires colors to be declared as XML resources in the host app — they
cannot be set programmatically. This script bridges the gap so both platforms
stay in sync from a single source of truth.

### Single source of truth

Edit **`example/lib/test_colors.dart`** to change any color. Both consumers
pick up the change automatically:

| Consumer | How it uses `test_colors.dart` |
|---|---|
| `example/lib/main.dart` (iOS runtime) | imports it directly via `dart:ui` `Color` |
| `tool/generate_android_colors.dart` | imports it as raw ARGB ints, writes XML |

### Usage

```sh
dart run tool/generate_android_colors.dart
```

Run from the repository root. The script overwrites:

- `example/android/app/src/main/res/values/colors.xml` — all color resources
- `example/android/app/src/main/res/values/styles.xml` — the
  `OneReaderFlatPlanArticleTitleTextView` style block (between the
  `[generated] MiniSummary` markers; the rest of the file is untouched)

### Color → resource name mapping

| `test_colors.dart` constant | Android resource |
|---|---|
| `kNavBarBackgroundLight/Dark` | `or_toolbar_background_color_light/dark` |
| `kNavBarButtonsTint` | `or_navigation_button_tint_light/dark` |
| `kNavBarTitleTextLight/Dark` | `or_toolbar_title_text_light/dark` |
| `kNavBarSubtitleText` | `or_toolbar_subtitle_text_light/dark` |
| `kNavBarProgressBg` | `or_progress_background_color` |
| `kNavBarProgressFill` | `or_progress_color` |
| `kNavBarLogoCapLight/Dark` | `or_logo_capsule_color_light/dark` |
| `kReaderBackground` | `or_background_color` |
| `kMiniSummaryCellTitle` | `OneReaderFlatPlanArticleTitleTextView` (style) |
| `kMiniSummarySeparator` | `or_mini_summary_separator_light/dark` |
