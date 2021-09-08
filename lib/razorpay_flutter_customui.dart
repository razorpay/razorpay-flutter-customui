
import 'dart:async';

import 'package:flutter/services.dart';

class RazorpayFlutterCustomui {
  static const MethodChannel _channel =
      const MethodChannel('razorpay_flutter_customui');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
