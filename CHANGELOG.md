## Unreleased

- Fixed iOS Amazon Pay wallet / PayLater payments not returning to checkout after OTP or insufficient-balance top-up:
  - Forward `WKNavigationDelegate.decidePolicyFor` to the SDK so `amazon.in` navigations are handed to the Amazon Pay SDK instead of loading in the webview.
  - Initialise the SDK with the Amazon Pay plugin (when the `razorpay-apay-wallet-paylater` pod is present) so it is available to the payment flow, not only to linking.
  - Handle `amzn-<bundle id>://` redirects via `application(_:open:options:)`, and `scene(_:openURLContexts:)` for apps on the UIScene lifecycle, and pass them to the Amazon Pay SDK.
- iOS payment error responses now include `code` and `description` when the SDK reports them only as arguments (previously such errors reached Dart as an empty map). Existing keys are unchanged.
- Guarded iOS plugin registration against a nil registrar to avoid a crash at launch.
- iOS: requires `razorpay-core-pod` 1.0.8 or later.
- Apps that override `application(_:open:options:)` must call `super` so plugins receive URL callbacks (needed for the Amazon Pay redirect).

## 1.5.0

- Added `getRecommendedInstruments` API for fetching ranked payment instrument suggestions.
- Added opt-in `unwrapData` parameter to `Razorpay.on(event, handler, {unwrapData})`. When `true`, handlers receive just the inner `data` map instead of the full `{type, data}` envelope, letting merchants share a single handler with `razorpay_flutter`'s `rawMap` opt-in. Default behavior is unchanged.

## 1.4.3

- Added Amazon Pay link-and-pay support.
- Fixed iOS resubmit crash and deprecated presentation issue.

## 1.4.2

- Bug-fix : Fixed `iOS native platform` errors due to internal libraries. 

## 1.4.1

- Bug-fix : Fixed `reply already submitted` intermittent error on getPaymentMethods function.

## 1.4.0

- Migrated to android v2 embedding.

## 1.3.3

- Removed JCenter from build.gradle for android due to Deprecation

## 1.3.2

- getBankLogoUrl Bug Fix

## 1.3.1

- Exposed getBankLogoUrl

## 1.3.0

- Added native dependency via cocoapods
- Minor bug fixes

## 1.2.3

- Dashboard Monitoring and Alerting
- Android bug fixes

## 1.2.2

- iOS bug fix on Payment cancel callback by the user
- Build issue fix on flutter run

## 1.2.1

- iOS bug fix for UPI supported Apps response.

## 1.2.0

- Validate VPA fixes

## 1.1.2

- Bug fixes on android

## 1.1.1

- Bug fixes

## 1.1.0

- Android Callback issue fixed.
- Added validate VPA.

## 1.0.0

- TODO: Describe initial release.
