import MiLibrisReaderSDK
import UIKit

/// Opens the MiLibris reader from a C-callable entry point.
/// Called via Dart FFI using @_cdecl to avoid any native code in the host app.
@_cdecl("milibris_open_reader")
public func milibrisOpenReader(
  _ releasePathPtr: UnsafePointer<CChar>,
  _ languageCodePtr: UnsafePointer<CChar>,
  _ configJsonPtr: UnsafePointer<CChar>
) {
  let releasePath = String(cString: releasePathPtr)
  let languageCodeStr = String(cString: languageCodePtr)
  let configJson = String(cString: configJsonPtr)

  DispatchQueue.main.async {
    let releaseUrl = URL(fileURLWithPath: releasePath)
    let languageCode = languageCodeStr.isEmpty ? nil : LanguageCode(rawValue: languageCodeStr)
    var config = ReaderConfig()

    // Apply Dart customization on top of defaults.
    if let data = configJson.data(using: .utf8),
       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
      applyCustomization(json, to: &config)
    }

    config.navigationBar.images.logo = UIImage(named: "Logo")
    config.articleReader.navigationBar.images.logo = UIImage(named: "Logo")

    let reader = Reader(
      releasePath: releaseUrl,
      articlesLanguageCode: languageCode,
      config: config
    )

    guard
      let windowScene = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .first(where: { $0.activationState == .foregroundActive }),
      let window = windowScene.windows.first(where: { $0.isKeyWindow }),
      let rootVC = window.rootViewController
    else { return }

    var topVC = rootVC
    while let presented = topVC.presentedViewController {
      topVC = presented
    }

    reader.presentReaderViewController(from: topVC)
  }
}

// MARK: - Config helpers

private func applyCustomization(_ json: [String: Any], to config: inout ReaderConfig) {
  if let navBar = json["navBar"] as? [String: Any] {
    applyNavBar(navBar, to: &config)
  }
  if let reader = json["reader"] as? [String: Any] {
    applyReader(reader, to: &config)
  }
  // miniSummary skipped — ReaderConfig has no miniSummary member in this SDK version.
}

private func applyNavBar(_ json: [String: Any], to config: inout ReaderConfig) {
  if let c = dynamicColor(json["background"]) {
    config.navigationBar.colors.background = c
    config.articleReader.navigationBar.colors.background = c
  }
  if let c = dynamicColor(json["buttonsTint"]) {
    config.navigationBar.colors.buttonsTint = c
    config.articleReader.navigationBar.colors.buttonsTint = c
  }
  if let c = dynamicColor(json["titleText"]) {
    config.navigationBar.colors.titleText = c
    config.articleReader.navigationBar.colors.titleText = c
  }
  // fonts.title / fonts.subtitle require a FontInfo value (SDK-specific type).
  // Consult the MiLibrisReaderSDK docs to construct one from titleFontName /
  // subtitleFontName and wire it up here.
  if let c = dynamicColor(json["subtitleText"]) {
    config.navigationBar.colors.subtitleText = c
    config.articleReader.navigationBar.colors.subtitleText = c
  }
  if let c = dynamicColor(json["progressbarBackground"]) {
    config.navigationBar.colors.progressbarBackground = c
  }
  if let c = dynamicColor(json["progressbarFill"]) {
    config.navigationBar.colors.progressbarFill = c
  }
  if let c = dynamicColor(json["logoBackground"]) {
    config.navigationBar.colors.logoBackground = c
    config.articleReader.navigationBar.colors.logoBackground = c
  }
}

private func applyReader(_ json: [String: Any], to config: inout ReaderConfig) {
  if let c = dynamicColor(json["background"]) {
    config.colors.background = c
  }
  if let v = json["isDoublePagesEnabled"] as? Bool {
    config.features.isDoublePagesEnabled = v
  }
  if let v = json["isSummaryEnabled"] as? Bool {
    config.features.isSummaryEnabled = v
    config.articleReader.features.isSummaryEnabled = v
  }
}


// MARK: - Color decoding

/// Decodes a color entry from JSON. Accepts either:
/// - A plain Int (ARGB) → fixed color
/// - A dict `{"light": Int, "dark": Int}` → dynamic UIColor
private func dynamicColor(_ value: Any?) -> UIColor? {
  if let argb = value as? Int {
    return UIColor(argb: argb)
  }
  if let dict = value as? [String: Any],
     let lightARGB = dict["light"] as? Int {
    let light = UIColor(argb: lightARGB)
    if let darkARGB = dict["dark"] as? Int {
      let dark = UIColor(argb: darkARGB)
      return UIColor { $0.userInterfaceStyle == .dark ? dark : light }
    }
    return light
  }
  return nil
}

private extension UIColor {
  /// Initialises from a 32-bit ARGB integer (as sent by Flutter's Color.toARGB32()).
  convenience init(argb: Int) {
    let a = CGFloat((argb >> 24) & 0xFF) / 255
    let r = CGFloat((argb >> 16) & 0xFF) / 255
    let g = CGFloat((argb >> 8)  & 0xFF) / 255
    let b = CGFloat( argb        & 0xFF) / 255
    self.init(red: r, green: g, blue: b, alpha: a)
  }
}
