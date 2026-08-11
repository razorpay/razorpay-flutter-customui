// Unit tests for the Apple Pay wrapper — device-independent.
// Mirrors the razorpay-flutter test convention: MethodChannel `log` +
// `isMethodCall` assertions + `expectAsync1` for eventify callbacks.
// Run with: flutter test

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:razorpay_flutter_customui/razorpay_flutter_customui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('razorpay_flutter_customui');
  final List<MethodCall> log = <MethodCall>[];
  late Razorpay razorpay;

  final applePayOptions = <String, dynamic>{
    'key': 'rzp_test_key',
    'order_id': 'order_1',
    'amount': '50000',
    'currency': 'INR',
    'contact': '9999999999',
    'email': 'user@example.com',
    'method': 'card',
    'app': {
      'name': 'apple_pay',
      'apple_pay': {'merchant_identifier': 'merchant.com.x'},
    },
  };

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall call) async {
      log.add(call);
      if (call.method == 'isApplePayAvailable') return true;
      return <String, dynamic>{};
    });
    razorpay = Razorpay();
    log.clear();
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
    razorpay.clear();
  });

  group('ApplePay.isAvailable', () {
    test('invokes isApplePayAvailable and returns the bool', () async {
      final available = await razorpay.applePay.isAvailable();
      expect(log, <Matcher>[isMethodCall('isApplePayAvailable', arguments: null)]);
      expect(available, isTrue);
    });
  });

  group('submit with apple_pay options', () {
    test('passes the apple_pay options through to native submit', () async {
      razorpay.submit(applePayOptions);
      expect(log, <Matcher>[isMethodCall('submit', arguments: applePayOptions)]);
    });

    test('fires payment.error (INVALID_OPTIONS) when key is missing', () async {
      final bad = Map<String, dynamic>.of(applePayOptions)..remove('key');
      razorpay.on(
        Razorpay.EVENT_PAYMENT_ERROR,
        expectAsync1((dynamic response) {
          expect(response, isNotNull);
        }, count: 1),
      );
      razorpay.submit(bad);
    });
  });
}
