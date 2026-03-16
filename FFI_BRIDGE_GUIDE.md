# Creating an FFI Bridge to a Native SDK

Here's what you'd create for each layer of the bridge:

---

## 1. C wrapper (`src/`) — the glue between Dart and the SDK

Since Dart FFI can only call C functions (not C++ or Obj-C directly), you write thin C wrappers around the SDK:

```c
// src/my_sdk_bridge.h
#include "path/to/MySdk.h"  // the SDK's own header

FFI_PLUGIN_EXPORT int sdk_do_something(int param);
FFI_PLUGIN_EXPORT const char* sdk_get_string();
```

```c
// src/my_sdk_bridge.c  (or .mm for Obj-C on iOS/macOS)
#include "my_sdk_bridge.h"

FFI_PLUGIN_EXPORT int sdk_do_something(int param) {
    return [MySdk doSomething:param];  // call the actual SDK
}
```

> If the SDK is Obj-C, use `.mm` (Objective-C++) instead of `.c`.

---

## 2. Dart bindings (`lib/`) — two files

**Auto-generated bindings** (run `dart run ffigen`):
```dart
// lib/my_sdk_bindings_generated.dart  ← generated, don't edit manually
// Contains NativeMySdkBindings class with all the C function signatures
```

**Hand-written Dart API** (like the existing `native_add.dart`):
```dart
// lib/my_sdk.dart
final DynamicLibrary _dylib = /* same platform loading logic */;
final NativeMySdkBindings _bindings = NativeMySdkBindings(_dylib);

String getSdkString() {
  final ptr = _bindings.sdk_get_string();
  return ptr.cast<Utf8>().toDartString();
}
```

---

## 3. `ffigen.yaml` — tells the binding generator what to parse

```yaml
name: NativeMySdkBindings
description: Bindings for My SDK
output: lib/my_sdk_bindings_generated.dart
headers:
  entry-points:
    - src/my_sdk_bridge.h
```

Then run:
```bash
dart run ffigen --config ffigen.yaml
```

---

## The full flow

```
Flutter/Dart app
    ↓ calls
lib/my_sdk.dart          ← your clean Dart API
    ↓ calls via FFI
lib/*_generated.dart     ← auto-generated C bindings
    ↓ calls
src/my_sdk_bridge.c/mm   ← your C/ObjC wrapper
    ↓ calls
Native SDK
```

The key insight: **you only write the C wrapper manually** — the Dart bindings are generated from its header.
