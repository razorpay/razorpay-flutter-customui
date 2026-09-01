import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:razorpay_flutter_customui/razorpay_flutter_customui.dart';

void main() {
  const MethodChannel channel = MethodChannel('razorpay_flutter_customui');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    // expect(await RazorpayFlutterCustomui.platformVersion, '42');
  });

  test('on() default (unwrapData: false) delivers the raw {type, data} envelope', () async {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'submit') {
        return {
          'type': 0,
          'data': {'razorpay_payment_id': 'pay_123'},
        };
      }
      if (methodCall.method == 'resync') return null;
      return null;
    });

    final razorpay = Razorpay();
    Map<dynamic, dynamic>? received;
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (Map<dynamic, dynamic> response) {
      received = response;
    });

    await razorpay.submit({'key': 'rzp_test_key'});

    expect(received, isNotNull);
    expect(received!['type'], 0);
    expect(received!['data'], {'razorpay_payment_id': 'pay_123'});
    expect(received!['razorpay_payment_id'], isNull);
  });

  test('on(unwrapData: true) delivers just the inner data map', () async {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'submit') {
        return {
          'type': 0,
          'data': {'razorpay_payment_id': 'pay_456'},
        };
      }
      if (methodCall.method == 'resync') return null;
      return null;
    });

    final razorpay = Razorpay();
    Map<dynamic, dynamic>? received;
    razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      (Map<dynamic, dynamic> response) {
        received = response;
      },
      unwrapData: true,
    );

    await razorpay.submit({'key': 'rzp_test_key'});

    expect(received, isNotNull);
    expect(received!['razorpay_payment_id'], 'pay_456');
    expect(received!.containsKey('type'), isFalse);
  });
}
