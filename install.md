# Test FFI Bridge — Setup Guide

This documents how to configure the environment so the **Test FFI Bridge** button in the example app succeeds on Android and iOS.

## Prerequisites

- A `.complete` archive downloaded from `https://content.milibris.com/access/<mid>/download.complete`
- The example app installed on the target device/simulator (run `flutter run` from `example/` at least once first)

---

## Android

The app uses `getExternalStorageDirectory()` (app-scoped external storage — no permissions required). Push the file directly there via adb.

```bash
# 1. Push the file directly to the app's external files directory
#    (adb has write access here without needing run-as)
adb push /path/to/<uuid>.complete /sdcard/Android/data/com.visuamobile.liberation/files/<uuid>.complete

# 2. Verify
adb shell ls -lh /sdcard/Android/data/com.visuamobile.liberation/files/
```

The app reads from `getExternalStorageDirectory()` which maps to `/sdcard/Android/data/com.visuamobile.liberation/files/`.

---

## iOS Simulator

```bash
# 1. Find the booted simulator UUID
xcrun simctl list devices | grep Booted

# 2. Get the app's data container path
APP_DIR=$(xcrun simctl get_app_container <simulator-uuid> fr.liberation.liberationapp data)
echo $APP_DIR

# 3. Copy the file into Application Support
mkdir -p "$APP_DIR/Library/Application Support"
cp /path/to/<uuid>.complete "$APP_DIR/Library/Application Support/"

# 4. Verify
ls -lh "$APP_DIR/Library/Application Support/"
```

The app reads from `getApplicationSupportDirectory()` which maps to `<container>/Library/Application Support/`.

### Example (iPhone 16 simulator, as of project setup)

```bash
APP_DIR=$(xcrun simctl get_app_container 464BCF33-F41F-4122-822D-444F3E18F784 fr.liberation.liberationapp data)
cp /Users/guillaume/Downloads/fc7558b2-3baf-46d5-82b1-7287a44cd269.complete "$APP_DIR/Library/Application Support/"
```

---

## iOS Real Device

Use Xcode's device file manager:

1. **Window → Devices and Simulators** → select your device
2. Select the app under **Installed Apps**
3. Click the **⚙️** icon → **Download Container...**
4. In Finder, right-click the downloaded `.xcappdata` → **Show Package Contents**
5. Drop the `.complete` file into `AppData/Library/Application Support/`
6. Drag the `.xcappdata` back onto the app in Xcode to re-upload

---

## Notes

- The `.complete` filename in `example/lib/main.dart` is hardcoded — update it if you use a different archive.
- The extraction destination is a fresh temp directory (`/tmp/mili_out`) that is wiped and recreated on each run.
