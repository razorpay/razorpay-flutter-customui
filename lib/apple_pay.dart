import 'package:eventify/eventify.dart';
import 'package:flutter/services.dart';

/// Apple Pay support (iOS only), modelled on the Amazon Pay slice.
///
/// The payment itself flows through the existing `razorpay.submit()` with the
/// Apple Pay options block, so no new payment-method name is introduced:
///
///   final razorpay = Razorpay();
///   razorpay.initilizeSDK('rzp_xxx');
///
///   // 1. Check eligibility (gate the Apple Pay button)
///   bool available = await razorpay.applePay.canMakePayment();
///
///   // 2. Pay — existing submit(), Apple Pay selected by options
///   razorpay.submit({
///     'key': 'rzp_xxx',
///     'order_id': 'order_xxx',
///     'amount': '50000',
///     'currency': 'INR',
///     'method': 'card',
///     'app': {
///       'name': 'apple_pay',
///       'apple_pay': {'merchant_identifier': 'merchant.com.yourcompany.app'},
///     },
///   });
class ApplePay {
  final MethodChannel _channel;
  // Kept for parity with AmazonPay (future events); unused for the capability check.
  // ignore: unused_field
  final EventEmitter _eventEmitter;

  ApplePay(this._channel, this._eventEmitter);

  /// Whether this customer can pay with Apple Pay right now. Use it to show or
  /// hide the Apple Pay button.
  ///
  /// Named `canMakePayment` per the API Council decision, matching the Web SDK and
  /// the native SDK's `razorpay.applePay.canMakePayment`.
  ///
  /// This is **merchant-aware**, not a device probe: it resolves true only when this
  /// merchant is live on Apple Pay *and* the wallet holds a card on a network that
  /// merchant accepts. A device that supports Apple Pay but has an empty wallet, or a
  /// merchant not enabled for it, resolves false.
  ///
  /// Returns false on Android, on the simulator, and when the optional
  /// `RazorpayApplePay` pod has not been added — so the button simply never shows.
  Future<bool> canMakePayment() async {
    try {
      final result = await _channel.invokeMethod('canMakePayment');
      return result == true;
    } catch (_) {
      return false;
    }
  }
}
