import 'package:eventify/eventify.dart';
import 'package:flutter/services.dart';

/// Amazon Pay wallet/paylater linking support.
///
/// Usage:
///   final razorpay = Razorpay();
///   razorpay.initilizeSDK('rzp_xxx');
///
///   // 1. Check availability
///   bool available = await razorpay.amazonPay.isAvailable();
///
///   // 2. Link Amazon Pay account
///   razorpay.amazonPay.startAuthorization(
///     customerId: 'cust_xxx',
///     onLinkingSuccessful: (data) => print('Linked!'),
///     onLinkingFailed: (error) => print('Failed: $error'),
///   );
///
///   // 3. Pay — uses existing razorpay.submit(), nothing new needed
///   razorpay.submit({
///     'key': 'rzp_xxx',
///     'method': 'wallet',
///     'wallet': 'amazonpay',
///     ...payment options...
///   });
class AmazonPay {
  final MethodChannel _channel;
  final EventEmitter _eventEmitter;

  static const EVENT_LINKING_SUCCESS = 'amazonpay.linking.success';
  static const EVENT_LINKING_ERROR = 'amazonpay.linking.error';

  AmazonPay(this._channel, this._eventEmitter);

  /// Initiates the Amazon Pay account linking flow.
  ///
  /// [customerId] — Razorpay customer ID (e.g. 'cust_xxx')
  /// [onLinkingSuccessful] — called when linking succeeds
  /// [onLinkingFailed] — called when linking fails
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
      } else {
        // Native returned null or an unexpected type — always fire onLinkingFailed
        // so the merchant is never left waiting with no feedback.
        final error = <dynamic, dynamic>{
          'code': -1,
          'message': 'Unexpected response from native layer: $result',
        };
        onLinkingFailed(error);
        _eventEmitter.emit(EVENT_LINKING_ERROR, null, error);
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

  /// Returns true if the Amazon Pay plugin is available on this device.
  Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod('isAmazonPayAvailable');
      return result == true;
    } catch (_) {
      return false;
    }
  }
}
