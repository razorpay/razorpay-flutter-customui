# Apple Pay for Flutter Custom UI — plan and verified facts

Working repo: `~/razorpay-flutter-customui` (durable — not a session scratchpad).
PR: https://github.com/razorpay/razorpay-flutter-customui/pull/112
Branch: `feat/apple-pay-wrapper`, base `master`. Currently `[WIP] ... (unbuilt, needs device QA)`.

Sibling work, **device-verified 17 Sep 2026**, and the reference for everything here:
https://github.com/razorpay/react-native-customui/pull/211 · evidence doc
`doc_lvwhgv6rl25pqcdv`. See memory `applepay-rn-wrapper`.

---

## Exact ObjC surface (from the shipped 2.2.3 / 2.2.0 headers — authoritative)

`RazorpayCheckout` (module `RazorpayCustom`, imported by the Flutter plugin already):
```objc
@property (nonatomic, strong) id <ApplePayPlugin> _Nullable applePay;   // -> setApplePay:
+ (RazorpayCheckout *)initWithKey:(NSString *)key
                      andDelegate:(id <RazorpayPaymentCompletionProtocol>)delegate
               withPaymentWebView:(WKWebView *)merchantWebView
                         ApplePay:(id <ApplePayPlugin>)applePayPlugin;
```

`ApplePayEntity` (module `RazorpayApplePay`) — the **entire** public surface:
```objc
@interface ApplePayEntity : NSObject <ApplePayPlugin>
- (void)setAnalyticsTracker:(void (^)(NSString *, NSDictionary * _Nullable))tracker;
- (void)initiateWithKey_id:(NSString *)key_id;
- (void)canMakePaymentWithCompletion:(void (^)(BOOL))completion;   // merchant-aware
- (instancetype)init;
@end
```

**Swift cannot use `NSInvocation`**, so RN's approach does not port literally. The clean
equivalent: declare a local `@objc protocol` in the Flutter plugin mirroring those four
selectors, create the instance via `NSClassFromString`, cast to the shim, and call typed
methods. No reflection gymnastics, and `canMakePaymentWithCompletion:` becomes directly
callable — which is what Stage 3 needs.

**Caveat to settle at build time:** `ApplePayPlugin` is only *forward-declared*
(`@protocol ApplePayPlugin;`) in `RazorpayCustom-Swift.h`. Whether Swift can name that
type for the typed 4-arg initialiser, or whether the assignment must go through
`setValue(_:forKey:)` / `perform`, is not answerable by reading — it needs a compile.

## Facts already verified on the RN side — do not re-derive

- The working way to attach the plugin is a **4-arg class initialiser** on
  `RazorpayCheckout`:
  `initWithKey:andDelegate:withPaymentWebView:ApplePay:`.
  It is what installs the Apple Pay analytics tracker.
- It does **not** call `initiate` on the plugin. `ApplePayEntity.merchantKey` is set
  **only** inside `initiate(key_id:)` (selector `initiateWithKey_id:`).
- **Order matters: attach first (tracker installed), then `initiate`.** The reverse
  drops every eligibility analytics event — `ApplePayAnalyticsSink.track` is a no-op
  while the sink is nil.
- Plugin conformer class name is `RazorpayApplePay.ApplePayEntity`. Confirmed.
- `RazorpayApplePay` is **not on the CocoaPods trunk** (SPM binary target / GitHub
  release asset only). It must stay opt-in; a hard dependency breaks `pod install`
  for every consumer.
- The plugin's own `canMakePayment(completion:)` is **merchant-aware**: it fetches
  `/v1/preferences` and calls `PKPaymentAuthorizationController.canMakePayments(usingNetworks:)`.
  It is currency-blind (known gap, Anand's side).
- `supportedNetworks(currency:)` excludes AMEX for non-INR. Verified visually.

## Repo rules (from this repo's own CLAUDE.md — read it before editing)

- **Every new native capability touches three places in lockstep**: the Dart method,
  the `case` in `RazorpayPlugin.java`'s switch, and the handler in
  `RazorpayDelegate.swift`. Missing one *silently* breaks one platform.
- `pubspec.yaml` and `ios/razorpay_flutter_customui.podspec` carry **independent**
  versions and must be kept in sync when releasing. (They are already out of sync
  today: pubspec `1.4.3`, podspec `1.3.2` — pre-existing drift, not ours to fix.)
- `CHANGELOG.md` gets an entry per release (see #114, the most recent feature merge).
- **There is no build or test CI in this repo.** `.github/workflows/security.yml` is
  dependency scanning only. Green checks prove nothing here — unlike the RN repo.
  The example app on a real device is the *only* real verification.
- No native unit tests exist. Dart-side: `flutter test`, `flutter analyze`.
- `master` is the live branch (#114 merged there 2 Sep; #107 synced it with
  release/v1.4.3). **No base-branch trap here** — unlike react-native-customui,
  where `master` was eight months stale.

---

## Findings on the current branch (all from code; no device needed)

1. **Apple Pay cannot work at all today — packaging.** The podspec never vends
   `RazorpayApplePay`, and pins `razorpay-customui-pod '~> 2.1.0'` (Apple Pay needs
   2.2.x). So `NSClassFromString("RazorpayApplePay.ApplePayEntity")` returns nil, the
   `if let pluginCls` guard fails, and the whole attach block is **silently skipped**.
2. **The attach API is valid after all — but may drop analytics.** *(Corrected after
   reading the checkout header; my earlier call that `setApplePay:` was a wrong guess
   was wrong. I had read the plugin source but not the host.)*
   `RazorpayCheckout` declares `@property (nonatomic, strong) id<ApplePayPlugin> applePay;`
   which generates `setApplePay:`. So the branch's setter path exists.
   **The open question is the analytics tracker.** The 4-arg initialiser is confirmed to
   install it; whether the property setter does is unknown and not answerable from the
   header. If it does not, eligibility analytics silently never fire — the same class of
   loss the ordering rule protects against.
   **Recommendation: use the 4-arg initialiser**, the only path with device evidence.
3. **`canMakePayment` is not merchant-aware.** `RazorpayDelegate.swift`
   `isApplePayAvailable` returns bare `PKPaymentAuthorizationController.canMakePayments()`
   — a device probe that is `true` even with an **empty Wallet**, regardless of merchant
   or accepted networks. This is the *inverse* of the RN defect: RN hid the button from
   people who could pay; this shows it to people who can't. The Dart doc comment in
   `lib/apple_pay.dart` claims *"Matches the React Native wrapper"* — now false.
4. **Ordering is inverted** — the branch calls `initiate` *before* attaching. See the
   ordering rule above.
5. **Repo conventions unmet**: no `pubspec.yaml` bump, no `CHANGELOG.md` entry, and no
   Apple Pay screen in `example/` (which is the only way to exercise native code here).

---

## Plan

### Stage 1 — packaging (unblocks everything else)
- Ship a `RazorpayApplePay.podspec` vending the xcframework, mirroring the RN one.
- Bump `razorpay-customui-pod` from `~> 2.1.0` to `~> 2.2.3`.
- Document the opt-in Podfile line in `README.md`.
- Keep `s.frameworks = 'PassKit'`.
- **Exit:** `pod install` resolves in `example/ios`, and the build still succeeds with
  the Apple Pay pod *absent* (negative case).

### Stage 2 — attach mechanism
- Replace the `setApplePay:` reflection with the verified 4-arg initialiser.
- Attach first, then `initiate` — with a comment saying why the order matters.
- Retain the checkout (RN hit an ARC release bug here; Flutter stores `self.razorpay`,
  so likely already fine — confirm, don't assume).
- Remove the `TODO(verify)` markers that are now answered.
- **Exit:** builds; plugin attaches on device.

### Stage 3 — merchant-aware `canMakePayment`
- Delegate to the plugin's own `canMakePayment(completion:)` instead of the bare
  PassKit probe. It is async and takes a completion, so the Dart side stays
  `Future<bool>` — **no public API change**.
- Requires the key, so the plugin must be initiated first (Stage 2).
- Fix the false parity claim in `lib/apple_pay.dart`.
- **Exit:** returns false for a merchant not live on Apple Pay; true for one that is.

### Stage 4 — repo conventions
- Bump `pubspec.yaml`; decide with the maintainer whether the podspec version follows.
- Add a `CHANGELOG.md` entry.
- Confirm and document that Android is a deliberate no-op: `canMakePayment` catches the
  `MissingPluginException` and returns false. Per the three-places-in-lockstep rule this
  must be *explicit*, not incidental.

### Stage 5 — example app (this is the test harness)
- Add an Apple Pay screen to `example/lib/`: eligibility gate, pay button, result log.
- Doubles as merchant-facing documentation, and is the only way to verify natively.

### Stage 6 — device QA (needs the phone)
- Same loop as RN: build to device, tap, collect payment IDs, confirm
  `APPLE_PAY_DECRYPTED_TOKEN_SUCCESS` and a distinct per-transaction cryptogram.
- Cover INR and a non-INR currency.
- Check the eligibility analytics actually fire (this is what the ordering rule protects).

### Stage 7 — land it
- Drop `[WIP]` from the title, rewrite the description with evidence.
- Request review. Ask Anand the same `initiate` question as on RN — if the initialiser
  should call it, both wrappers lose their explicit call.

---

## Naming — no new merchant-facing names are needed, and none are introduced

Checked against every other surface. The Dart API on the branch is **already correct**:

| Surface | Eligibility call | Payment call |
|---|---|---|
| Native iOS | `razorpay.applePay.canMakePayment` | `authorize(options)` + `app.apple_pay` |
| Web SDK | `canMakePayment` | same options block |
| React Native (shipped) | `Razorpay.canMakePayment(keyId)` | `open(options)` |
| **Flutter (this branch)** | **`razorpay.applePay.canMakePayment()`** | **`submit(options)`** |

Flutter's is the closest of all of them to native — same `applePay.canMakePayment`
shape, because it follows the existing `razorpay.amazonPay` sub-API precedent. Keep it.

No new payment-method name is introduced either: Apple Pay rides the existing
`submit()` with `method: 'card'` and `app: {name: 'apple_pay'}`. Same as native, Web
and RN.

**One internal name to change.** The MethodChannel string is `isApplePayAvailable`,
which matches nothing else. It is invisible to merchants, so this is a rename with zero
API impact — but per the three-places-in-lockstep rule the channel name should read the
same as the Dart method. **Rename the channel method to `canMakePayment`.** Not a new
name; one fewer.

## What the merchant does — the exact and complete list

**Build config (4 steps, one-time):**
1. `flutter pub get` on the version carrying Apple Pay.
2. Add **one line** to the app's `ios/Podfile`:
   ```ruby
   pod 'RazorpayApplePay',
       :podspec => '.symlinks/plugins/razorpay_flutter_customui/ios/RazorpayApplePay.podspec'
   ```
3. `cd ios && pod install`.
4. Xcode: target > Signing & Capabilities > + Capability > **Apple Pay**, tick the
   merchant identifier. It **must** equal the `merchant_identifier` passed at runtime.

**Code (2 changes):**
5. Gate the button: `if (await razorpay.applePay.canMakePayment()) { ...show it... }`
6. Pay with the **existing** `submit()`, adding only the `app` block:
   ```dart
   razorpay.submit({
     'key': 'rzp_live_xxx', 'order_id': 'order_xxx',
     'amount': '50000', 'currency': 'INR', 'method': 'card',
     'app': {'name': 'apple_pay',
             'apple_pay': {'merchant_identifier': 'merchant.com.yourcompany.app'}},
   });
   ```

**Result handling: nothing at all.** Apple Pay resolves through the same
`razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS / EVENT_PAYMENT_ERROR)` listeners the
merchant already uses for cards. Same envelope, same events. A merchant already taking
card payments writes **zero** new result-handling code — identical to the RN finding.

**Merchant does NOT supply:** `country_code` or `label`. The SDK derives both
(`country_code` defaults to `IN`; `label` comes from the brand name in `/v1/preferences`).
Passing `label` risks showing a name inconsistent with the rest of their checkout.

**Android:** no steps. `canMakePayment()` returns `false`; the button is hidden.

## Open decision (flagged in the PR's own comment)

**(a) typed import** — `import RazorpayApplePay` and use the compiler-checked
`ApplePay.pluginInstance()`. Cleaner, but forces the module on every Flutter consumer.

**(b) reflection** — what the branch does and what RN shipped and device-proved.

**Recommendation: (b).** It preserves the opt-in packaging that (a) would defeat, and it
is the only one of the two with device evidence behind it.

---

## Dos and don'ts carried over

- **Read the plugin source before theorising.** Three wrong hypotheses in one night on
  the RN side, all killable by reading `ApplePayPluginEntity.swift`.
- **Check the phone is online first.** A network-dependent call failing while a local
  one succeeds means connectivity, not a bug. Cost an hour.
- Live-key testing trips Shield's `INTL_DDOS_RULE` on small amounts with no order. Use
  >= ~$2 **and** a server-created order.
- `errSecInternalComponent` on CLI codesign -> build from the Xcode GUI.
- Never run a CLI build while Xcode is building; they collide on `build.db`.
- A `responds(to:)`-guarded reflective call that silently no-ops is the dominant failure
  mode in both wrappers. Log the negative branch; never let it fail silently.
