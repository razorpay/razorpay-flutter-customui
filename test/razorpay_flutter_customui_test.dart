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
}
