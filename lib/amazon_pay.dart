import 'package:eventify/eventify.dart';
import 'package:flutter/services.dart';

/// Amazon Pay wallet/paylater linking and payment support.
///
/// This class exposes the Amazon Pay Link-n-Pay flow for Flutter,
/// bridging to the native Android (`amazonPayWallet.startAuthorization`)
/// and iOS (`amazonPay?.startAuthorization`) SDKs.
///
/// Usage:
/// ```dart
/// final razorpay = Razorpay('rzp_test_xxx');
///
/// // 1. Link Amazon Pay account
/// razorpay.amazonPay.startAuthorization(
///   customerId: 'cust_xxx',
///   onLinkingSuccessful: (data) {
///     print('Linked! Token: ${data['token']}');
///   },
///   onLinkingFailed: (error) {
///     print('Linking failed: $error');
///   },
/// );
///
/// // 2. Make wallet payment with linked token
/// razorpay.submit({
///   'key': 'rzp_test_xxx',
///   'amount': 100,
///   'currency': 'INR',
///   'email': 'test@razorpay.com',
///   'contact': '9999999999',
///   'order_id': 'order_xxx',
///   'customer_id': 'cust_xxx',
///   'method': 'wallet',
///   'wallet': 'amazonpay',
///   'token': 'token_from_fetch_balance',
/// });
///
/// // 3. Make paylater payment with linked token
/// razorpay.submit({
///   'key': 'rzp_test_xxx',
///   'amount': 100,
///   'currency': 'INR',
///   'email': 'test@razorpay.com',
///   'contact': '9999999999',
///   'order_id': 'order_xxx',
///   'customer_id': 'cust_xxx',
///   'method': 'paylater',
///   'provider': 'amazonpay',
///   'token': 'token_from_fetch_balance',
/// });
/// ```
class AmazonPay {
  final MethodChannel _channel;
  final EventEmitter _eventEmitter;

  // Event names for Amazon Pay linking
  static const EVENT_LINKING_SUCCESS = 'amazonpay.linking.success';
  static const EVENT_LINKING_ERROR = 'amazonpay.linking.error';

  AmazonPay(this._channel, this._eventEmitter);

  /// Initiates the Amazon Pay account linking flow.
  ///
  /// This triggers the native Amazon Pay authorization on Android/iOS.
  /// The user will be presented with the Amazon consent screen to link
  /// their Amazon account with the merchant's Razorpay customer.
  ///
  /// Parameters:
  /// - [customerId]: Razorpay customer ID (e.g. 'cust_xxx')
  /// - [onLinkingSuccessful]: Called when linking succeeds. Receives a Map
  ///   with linking details (varies by platform).
  /// - [onLinkingFailed]: Called when linking fails. Receives error details.
  ///
  /// Android: Calls `razorpay.amazonPayWallet.startAuthorization(activity, customerId, callback)`
  /// iOS: Calls `razorpay.amazonPay?.startAuthorization(customerId, delegate)`
  Future<void> startAuthorization({
    required String customerId,
    required Function(Map<dynamic, dynamic> data) onLinkingSuccessful,
    required Function(Map<dynamic, dynamic> error) onLinkingFailed,
  }) async {
    try {
      final result = await _channel.invokeMethod(
        'amazonPayStartAuthorization',
        {'customerId': customerId},
      );

      if (result != null && result is Map) {
        final resultMap = Map<dynamic, dynamic>.from(result);
        if (resultMap['type'] == 'success') {
          final data = resultMap['data'] != null
              ? Map<dynamic, dynamic>.from(resultMap['data'] as Map)
              : <dynamic, dynamic>{};
          onLinkingSuccessful(data);
          _eventEmitter.emit(EVENT_LINKING_SUCCESS, null, data);
        } else {
          final error = resultMap['data'] != null
              ? Map<dynamic, dynamic>.from(resultMap['data'] as Map)
              : <dynamic, dynamic>{'message': 'Unknown error'};
          onLinkingFailed(error);
          _eventEmitter.emit(EVENT_LINKING_ERROR, null, error);
        }
      }
    } on PlatformException catch (e) {
      final error = <dynamic, dynamic>{
        'code': e.code,
        'message': e.message ?? 'Platform error during Amazon Pay linking',
      };
      onLinkingFailed(error);
      _eventEmitter.emit(EVENT_LINKING_ERROR, null, error);
    }
  }

  /// Checks if the Amazon Pay plugin/SDK is available on this device.
  ///
  /// Returns `true` if the native Amazon Pay SDK classes are present.
  Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod('isAmazonPayAvailable');
      return result == true;
    } catch (_) {
      return false;
    }
  }
}
