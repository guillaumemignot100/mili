import 'dart:ui';

/// A color with separate light and dark mode variants.
///
/// On Android, [light] maps to the `_light` resource name and [dark] maps
/// to the `_dark` resource name. If [dark] is omitted, only the light
/// resource is applied.
///
/// On iOS, both values are combined into a single dynamic [UIColor] that
/// automatically adapts to the system appearance. If [dark] is omitted, the
/// [light] color is used for both modes.
class ReaderColor {
  /// Creates a [ReaderColor] with explicit light and optional dark variants.
  const ReaderColor({required this.light, this.dark});

  /// Creates a [ReaderColor] that uses [color] for both light and dark modes.
  const ReaderColor.unified(Color color) : light = color, dark = null;

  /// The color used in light mode (and in dark mode when [dark] is null).
  final Color light;

  /// The color used in dark mode. Defaults to [light] when null.
  final Color? dark;
}

/// Customization for the reader navigation bar.
class NavBarCustomization {
  /// Creates a [NavBarCustomization].
  const NavBarCustomization({
    this.backgroundColor,
    this.buttonsTintColor,
    this.titleTextColor,
    this.titleFontName,
    this.subtitleTextColor,
    this.subtitleFontName,
    this.progressbarBackgroundColor,
    this.progressbarFillColor,
    this.logoBackgroundColor,
    this.logoBorderColor,
  });

  /// Android: `or_toolbar_background_color_light/_dark`
  /// iOS: `colors.background`
  final ReaderColor? backgroundColor;

  /// Android: `or_navigation_button_tint_light`
  /// iOS: `colors.buttonsTint`
  final ReaderColor? buttonsTintColor;

  /// Android: `or_toolbar_title_text_light`
  /// iOS: `colors.titleText`
  final ReaderColor? titleTextColor;

  /// Android: `ORH1` text appearance / iOS: `fonts.title`
  final String? titleFontName;

  /// Android: `or_toolbar_subtitle_text_light`
  /// iOS: `colors.subtitleText`
  final ReaderColor? subtitleTextColor;

  /// Android: `ORTiny` text appearance / iOS: `fonts.subtitle`
  final String? subtitleFontName;

  /// Android: `or_progress_background_color`
  /// iOS: `colors.progressbarBackground`
  final ReaderColor? progressbarBackgroundColor;

  /// Android: `or_progress_color`
  /// iOS: `colors.progressbarFill`
  final ReaderColor? progressbarFillColor;

  /// Android: `or_logo_capsule_color_light`
  /// iOS: `colors.logoBackground`
  final ReaderColor? logoBackgroundColor;

  /// iOS: `colors.logoBorder`
  final ReaderColor? logoBorderColor;
}

/// Customization for the main reader view.
class ReaderViewCustomization {
  /// Creates a [ReaderViewCustomization].
  const ReaderViewCustomization({
    this.backgroundColor,
    this.isDoublePagesEnabled,
    this.isSummaryEnabled,
  });

  /// Android: `or_background_color`
  /// iOS: `colors.background`
  final ReaderColor? backgroundColor;

  /// Android: `enabledDoublePage` / iOS: `features.isDoublePagesEnabled`
  final bool? isDoublePagesEnabled;

  /// Android: `isSummaryEnabled` / iOS: `features.isSummaryEnabled`
  final bool? isSummaryEnabled;
}

/// Customization for the mini summary strip at the bottom of the reader.
class MiniSummaryCustomization {
  /// Creates a [MiniSummaryCustomization].
  const MiniSummaryCustomization({
    this.cellTitleTextColor,
    this.separatorColor,
  });

  /// Android: `OneReaderFlatPlanArticleTitleTextView`
  /// iOS: `colors.miniSummaryCellTitleText`
  final ReaderColor? cellTitleTextColor;

  /// Android: `or_mini_summary_separator_light`
  /// iOS: `colors.miniSummarySeparator`
  final ReaderColor? separatorColor;
}

/// Top-level customization passed to [MilibrisFFI.openReader].
class ReaderCustomization {
  /// Creates a [ReaderCustomization].
  const ReaderCustomization({this.navBar, this.reader, this.miniSummary});

  /// Customization applied to the navigation bar.
  final NavBarCustomization? navBar;

  /// Customization applied to the main reader view.
  final ReaderViewCustomization? reader;

  /// Customization applied to the mini summary strip.
  final MiniSummaryCustomization? miniSummary;
}
