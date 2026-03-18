import MiLibrisReaderSDK
import UIKit

/// Opens the MiLibris reader from a C-callable entry point.
/// Called via Dart FFI using @_cdecl to avoid any native code in the host app.
@_cdecl("milibris_open_reader")
public func milibrisOpenReader(
  _ releasePathPtr: UnsafePointer<CChar>,
  _ languageCodePtr: UnsafePointer<CChar>
) {
  let releasePath = String(cString: releasePathPtr)
  let languageCodeStr = String(cString: languageCodePtr)

  DispatchQueue.main.async {
    let releaseUrl = URL(fileURLWithPath: releasePath)
    let languageCode = languageCodeStr.isEmpty ? nil : LanguageCode(rawValue: languageCodeStr)
    var config = ReaderConfig()
    config.features.printPageEnabled = true
    config.features.isSummaryEnabled = false
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
