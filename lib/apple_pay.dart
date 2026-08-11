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
///   // 1. Check availability (gate the Apple Pay button)
///   bool available = await razorpay.applePay.isAvailable();
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

  /// Returns true if this device can present Apple Pay (Wallet + an eligible
  /// card). Always false on the simulator. Use it to show/hide the Apple Pay
  /// button.
  Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod('isApplePayAvailable');
      return result == true;
    } catch (_) {
      return false;
    }
  }
}
