import 'dart:async';
import 'package:eventify/eventify.dart';
import 'package:flutter/services.dart';
import 'Tpv.dart';
import 'upi_turbo.dart';
import 'dart:io' show Platform;

class Razorpay {
  // Response codes from platform
  static const _CODE_PAYMENT_SUCCESS = 0;
  static const _CODE_PAYMENT_ERROR = 1;

  // Event names
  static const EVENT_PAYMENT_SUCCESS = 'payment.success';
  static const EVENT_PAYMENT_ERROR = 'payment.error';
  static const EVENT_UPI_TURBO_LINK_NEW_UPI_ACCOUNT = "linkNewUpiAccount";

  // Payment error codes
  static const NETWORK_ERROR = 0;
  static const INVALID_OPTIONS = 1;
  static const PAYMENT_CANCELLED = 2;
  static const TLS_ERROR = 3;
  static const INCOMPATIBLE_PLUGIN = 4;
  static const UNKNOWN_ERROR = 100;
  static const MethodChannel _channel = const MethodChannel('razorpay_turbo');
  late EventEmitter _eventEmitter;
  late UpiTurbo upiTurbo;
  late Tpv tpv;

  Razorpay(String key) {
    _channel.invokeMethod('initilizeSDK', key);
    _eventEmitter = new EventEmitter();
    upiTurbo = new UpiTurbo(_channel, _eventEmitter);
    tpv = Tpv(_channel, _eventEmitter);
  }
  Razorpay.initWith(String key, bool ui) {
    if (Platform.isAndroid) {
       _channel.invokeMethod('initilizeSDK', key);
      // Android-specific code
    } else if (Platform.isIOS) {
      final Map<dynamic, dynamic> keyFinal = {'key':key,'ui':ui};
      _channel.invokeMethod('initilizeSDK', keyFinal);
    }
    _eventEmitter = new EventEmitter();
    upiTurbo = new UpiTurbo(_channel, _eventEmitter);
    tpv = Tpv(_channel, _eventEmitter);
  }
  // Maintain a map to store callbacks for each data exchange
  final Map<String, Function(dynamic)> _callbackMap = {};

  // Register a callback for the specified identifier
  void registerCallback(String identifier, Function(dynamic) callback) {
    _callbackMap[identifier] = callback;
  }

  // Unregister the callback for the specified identifier
  void unregisterCallback(String identifier) {
    _callbackMap.remove(identifier);
  }

  // Called when data is received from the Android side
  void onDataReceived(Map<String, dynamic> data) {
    final identifier = data['identifier'];
    final callback = _callbackMap[identifier];
    if (callback != null) {
      callback(data['data']);
    }
  }

  Future<Map<dynamic, dynamic>> getPaymentMethods() async {
    final Map<dynamic, dynamic> paymentMethodsObj =
        await _channel.invokeMethod('getPaymentMethods');
    return paymentMethodsObj;
  }

  Future<dynamic> getAppsWhichSupportUpi() async {
    final paymentMethodsObj =
        await _channel.invokeMethod('getAppsWhichSupportUpi');
    return paymentMethodsObj;
  }

  Future<String> getCardsNetwork(String cardNumber) async {
    final String cardNetwork =
        await _channel.invokeMethod('getCardNetwork', cardNumber);
    return cardNetwork;
  }

  Future<bool> isCredAppAvailable() async {
    final bool isCredAppPresent =
        await _channel.invokeMethod('isCredAppAvailable');
    return isCredAppPresent;
  }

  Future<String> getWalletLogoUrl(String walletName) async {
    final walletLogoUrl =
        await _channel.invokeMethod('getWalletLogoUrl', walletName);
    return walletLogoUrl;
  }

  Future<String> getBankLogoUrl(String bankName) async {
    final bankLogoUrl = await _channel.invokeMethod('getBankLogoUrl', bankName);
    return bankLogoUrl;
  }

  Future<dynamic> getSubscriptionAmount(String subscriptionId) async {
    final dynamic subscriptionAmount =
        await _channel.invokeMethod('getSubscriptionAmount', subscriptionId);
    return subscriptionAmount;
  }

  Future<dynamic> getCardNetworkLength(String network) async {
    final dynamic cardNetworkLength =
        await _channel.invokeMethod('getCardNetworkLength', network);
    return cardNetworkLength;
  }

  Future<bool> isValidCardNumber(String network) async {
    final dynamic isValidCard =
        await _channel.invokeMethod('isValidCardNumber', network);
    return isValidCard;
  }

  Future<Map<dynamic, dynamic>> isValidVpa(String vpa) async {
    final dynamic isValidVpa = await _channel.invokeMethod('isValidVpa', vpa);
    return isValidVpa;
  }

  submit(Map<String, dynamic> options) async {
    Map<String, dynamic> validationResult = _validateOptions(options);

    if (!validationResult['success']) {
      _handleResult({
        'type': _CODE_PAYMENT_ERROR,
        'data': {
          'code': INVALID_OPTIONS,
          'message': validationResult['message']
        }
      });
      return;
    }

    var response = await _channel.invokeMethod('submit', options);
    _handleResult(response);
  }

  payWithCred(Map<String, dynamic> options) async {
    Map<String, dynamic> validationResult = _validateOptions(options);

    if (!validationResult['success']) {
      _handleResult({
        'type': _CODE_PAYMENT_ERROR,
        'data': {
          'code': INVALID_OPTIONS,
          'message': validationResult['message']
        }
      });
      return;
    }

    var response = await _channel.invokeMethod('payWithCred', options);
    _handleResult(response);
  }

  /// Handles checkout response from platform
  _handleResult(Map<dynamic, dynamic> response) {
    String eventName;

    dynamic payload;

    if (response['razorpay_payment_id'] != null ||
        response['type'] == _CODE_PAYMENT_SUCCESS) {
      eventName = EVENT_PAYMENT_SUCCESS;
      payload = response;
    } else {
      eventName = EVENT_PAYMENT_ERROR;
      payload = response;
    }
    _eventEmitter.emit(eventName, null, payload);
  }

  /// Registers event listeners for payment events
  void on(String event, Function handler) {
    EventCallback cb = (event, cont) {
      handler(event.eventData);
    };
    _eventEmitter.on(event, null, cb);
    _resync();
  }

  /// Retrieves lost responses from platform
  void _resync() async {
    var response = await _channel.invokeMethod('resync');
    if (response != null) {
      _handleResult(response);
    }
  }

  void clear() {
    _eventEmitter.clear();
  }

  /// Validate payment options
  static Map<String, dynamic> _validateOptions(Map<String, dynamic> options) {
    if (options['upiAccount'] != null) {
      if (options['payload'] != null) {
        if (options['payload']['key'] != null) {
          return {'success': true};
        }
      }
    }

    var key = options['key'];
    if (key == null) {
      return {
        'success': false,
        'message': 'Key is required. Please check if key is present in options.'
      };
    }
    return {'success': true};
  }
}

class PaymentSuccessResponse {
  String paymentId;
  String orderId;
  String signature;

  PaymentSuccessResponse(this.paymentId, this.orderId, this.signature);

  static PaymentSuccessResponse fromMap(Map<dynamic, dynamic> map) {
    String paymentId = map["razorpay_payment_id"];
    String signature = map["razorpay_signature"];
    String orderId = map["razorpay_order_id"];

    return new PaymentSuccessResponse(paymentId, orderId, signature);
  }
}

class PaymentFailureResponse {
  int code;
  String message;

  PaymentFailureResponse(this.code, this.message);

  static PaymentFailureResponse fromMap(Map<dynamic, dynamic> map) {
    var code = map["http_status_code"] as int;
    var message = map["metadata.reason"] as String;
    return new PaymentFailureResponse(code, message);
  }
}





