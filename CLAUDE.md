# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Flutter plugin that wraps Razorpay's **Custom UI** (headless/native) Android and iOS SDKs, as opposed to the standard `razorpay_flutter` package which wraps Razorpay's hosted checkout. Because the underlying SDK is headless, this plugin exposes many more native calls (card/VPA/UPI validation, wallet/bank logo lookups, subscription amounts, CRED and Amazon Pay flows) than the standard checkout wrapper — merchants build their own payment UI in Dart and call into the native SDK for data and payment submission.

Package id: `razorpay_flutter_customui`. Published to pub.dev; current version tracked in `pubspec.yaml` (`ios/razorpay_flutter_customui.podspec` has its own, independently-bumped version — keep both in sync when releasing).

## Commands

```bash
flutter pub get                    # install deps (run in repo root and in example/)
flutter test                       # run Dart unit tests (test/razorpay_flutter_customui_test.dart)
flutter test test/some_test.dart   # run a single test file
flutter analyze                    # static analysis
cd example && flutter run          # run the example app (needs a real device/emulator + Razorpay test key)
cd ios && pod install               # after native iOS changes, from example/ios or a consuming app's ios/ dir
```

There is no Android/iOS unit test suite in this repo — native code is exercised only through the example app on a real device/emulator. `.github/workflows/security.yml` is the only CI workflow (dependency/security scanning via Dependabot), not a build/test pipeline.

## Architecture

Standard Flutter plugin split across three platform implementations behind one `MethodChannel` named `razorpay_flutter_customui`:

- **`lib/razorpay_flutter_customui.dart`** — the public Dart API (`Razorpay` class). Wraps the channel with typed methods (`submit`, `initilizeSDK`, `getPaymentMethods`, `isValidVpa`, `getCardsNetwork`, etc.) and an `eventify`-based `EventEmitter` for `EVENT_PAYMENT_SUCCESS` / `EVENT_PAYMENT_ERROR` callbacks registered via `.on(...)`. `payWithCred` follows the same submit/validate/callback pattern as `submit` for CRED-specific payments.
- **`lib/amazon_pay.dart`** — `AmazonPay` class, a sub-API reachable via `Razorpay().amazonPay`. Handles Amazon Pay account linking (`startAuthorization`, `isAvailable`) over the *same* method channel, emitting its own `amazonpay.linking.success` / `amazonpay.linking.error` events. Native support for this is compile-time optional on Android (see below).
- **`lib/razorpay_flutter_customui_web.dart`** — web platform stub; only implements `getPlatformVersion`, everything else is unimplemented for web.
- **`android/src/main/java/com/razorpay/flutter_customui/`**:
  - `RazorpayPlugin.java` — `MethodCallHandler` that switches on `call.method` and delegates to `RazorpayDelegate`. This is the single place new Dart↔native methods must be wired up on Android.
  - `RazorpayDelegate.java` — talks to the native `com.razorpay.Razorpay` SDK directly for query-style calls (logos, validation, subscription amount), and launches `RazorpayPaymentActivity` for anything that opens a payment UI. The Amazon Pay import (`com.razorpay.AmazonPayAuthCodeCallback`) is a `compileOnly` dependency — it must stay null-safe at runtime for merchants who haven't added the Amazon Pay wallet/paylater native artifact.
  - `RazorpayPaymentActivity.java` — a real `Activity` implementing `PaymentResultWithDataListener`; it's what's actually started for `submit`/`payWithCred`, since Razorpay Custom UI needs its own Activity to receive `onActivityResult` from bank/UPI/wallet apps. Persists `payload` across `onCreate`/`savedInstanceState` to survive process death during a payment. `onActivityResult` uses reflection to call a 4-arg overload of `razorpay.onActivityResult(...)` when available, falling back to the 3-arg form — this avoids hard-coupling to a specific Razorpay Android SDK version.
  - `Constants.java` — shared Intent extra keys (`OPTIONS`, `PAYMENT_DATA`, etc.) passed between the plugin, delegate, and activity.
- **`ios/Classes/`**:
  - `SwiftRazorpayFlutterCustomuiPlugin.swift` — Flutter plugin entrypoint, registers the method channel.
  - `RazorpayDelegate.swift` — iOS counterpart to the Android delegate; talks to the vendored `Razorpay.xcframework` / `razorpay-customui-pod` CocoaPod.
  - `RazorpayFlutterCustomuiPlugin.h`/`.m` — Objective-C shims required for Flutter plugin registration alongside the Swift implementation.

### Cross-cutting patterns worth knowing before changing the API surface

- Every new native capability requires touching **three** places in lockstep: the Dart method in `lib/razorpay_flutter_customui.dart` (or `amazon_pay.dart`), the `case` in `RazorpayPlugin.java`'s switch, and the corresponding handler in `RazorpayDelegate.swift` on iOS. Missing one silently breaks one platform.
- Payment submission (`submit`, `payWithCred`) is asynchronous across an `Activity` boundary on Android — results come back through `onActivityResult`, not a direct method return, and `resync()` exists specifically to recover a result that arrived while Flutter/Dart wasn't listening (e.g. after app restart/process death). Don't assume `_channel.invokeMethod('submit', ...)` completing means the payment finished.
- `_validateOptions` in Dart only checks for `key` before calling native `submit`/`payWithCred` — don't assume deeper option validation happens client-side; most validation is native-side.

## Native SDK dependency

The plugin vends the Razorpay Custom UI native SDKs rather than the standard Razorpay Android/iOS SDK — do not confuse APIs/behavior with the `razorpay-android`/`razorpay-pod` used by the plain `razorpay_flutter` package. Proguard rules for consuming apps are documented in `README.md` and must keep `com.razorpay.**` and `onPayment*` methods unobfuscated.
