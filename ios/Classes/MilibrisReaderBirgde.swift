import MiLibrisReaderSDK

/// Extracts a Milibris .complete archive to the given directory.
///
/// Exported as a C symbol so it can be called from Dart via dart:ffi.
///
/// - Parameters:
///   - archivePath: C string – absolute path to the .complete archive file.
///   - destPath:    C string – absolute path to the destination directory.
/// - Returns: 0 on success, -1 on invalid arguments, -2 on extraction failure.
@_cdecl("milibris_extract_archive")
public func milibrisExtractArchive(
  archivePath: UnsafePointer<CChar>?,
  destPath: UnsafePointer<CChar>?
) -> Int32 {
  guard let archivePath: UnsafePointer<CChar>, let destPath else { return -1 }

  let archiveURL = URL(fileURLWithPath: String(cString: archivePath))
  let destURL = URL(fileURLWithPath: String(cString: destPath))

  do {
    try MLArchive.extract(archiveURL, inDirectory: destURL)
    return 0
  } catch {
    return -2
  }
}
