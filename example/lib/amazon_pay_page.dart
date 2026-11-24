import 'package:flutter/material.dart';
import 'package:razorpay_flutter_customui/razorpay_flutter_customui.dart';

/// Amazon Pay Link-n-Pay test screen.
///
/// Flow: Init SDK -> Link Amazon (consent) -> fetch the wallet token on your backend with the
/// Fetch Balance API -> Pay with wallet or Pay Later using that token.
///
/// Key, customer and token can be passed at run time instead of typing them:
///   flutter run --dart-define=AMAZON_PAY_KEY=rzp_xxx --dart-define=AMAZON_PAY_CUSTOMER_ID=cust_xxx \
///     --dart-define=AMAZON_PAY_TOKEN=token_from_fetch_balance
///
/// iOS needs the razorpay-apay-wallet-paylater pod, plus APIKey and the amzn-<bundle id> URL scheme
/// in Info.plist (see ios/Runner/Info.plist).
class AmazonPayPage extends StatefulWidget {
  @override
  _AmazonPayPageState createState() => _AmazonPayPageState();
}

class _AmazonPayPageState extends State<AmazonPayPage> {
  final _razorpay = Razorpay();
  final _key = TextEditingController(text: const String.fromEnvironment('AMAZON_PAY_KEY'));
  final _customerId = TextEditingController(text: const String.fromEnvironment('AMAZON_PAY_CUSTOMER_ID'));
  final _token = TextEditingController(text: const String.fromEnvironment('AMAZON_PAY_TOKEN'));
  final _orderId = TextEditingController();
  final _amount = TextEditingController(text: '100');
  final _log = <String>[];

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (response) => _add('SUCCESS: $response'));
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) => _add('ERROR: $response'));
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _add(String line) {
    debugPrint('[AmazonPayExample] $line');
    setState(() => _log.insert(0, line));
  }

  Map<String, dynamic> _paymentOptions(Map<String, dynamic> methodOptions) => {
        'key': _key.text.trim(),
        'amount': int.tryParse(_amount.text) ?? 100,
        'currency': 'INR',
        'email': 'test@example.com',
        'contact': '9999999999',
        'customer_id': _customerId.text.trim(),
        'token': _token.text.trim(),
        if (_orderId.text.trim().isNotEmpty) 'order_id': _orderId.text.trim(),
        ...methodOptions,
      };

  void _init() {
    _razorpay.initilizeSDK(_key.text.trim());
    _add('initilizeSDK(${_key.text.trim()})');
  }

  Future<void> _isAvailable() async {
    _add('amazonPay.isAvailable = ${await _razorpay.amazonPay.isAvailable()}');
  }

  Future<void> _link() async {
    _add('startAuthorization(${_customerId.text.trim()})');
    await _razorpay.amazonPay.startAuthorization(
      customerId: _customerId.text.trim(),
      onLinkingSuccessful: (data) => _add('LINKED: $data'),
      onLinkingFailed: (error) => _add('LINK FAILED: $error'),
    );
  }

  void _pay(String label, Map<String, dynamic> methodOptions) {
    final options = _paymentOptions(methodOptions);
    _add('submit $label: $options');
    _razorpay.submit(options);
  }

  Widget _field(String label, TextEditingController controller) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label, isDense: true, border: const OutlineInputBorder()),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Amazon Pay (Link & Pay)')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field('Razorpay key', _key),
            _field('Customer ID (cust_...)', _customerId),
            _field('Token from Fetch Balance', _token),
            _field('Order ID (optional)', _orderId),
            _field('Amount (paise)', _amount),
            Wrap(spacing: 8, runSpacing: 8, children: [
              ElevatedButton(onPressed: _init, child: const Text('1. Init SDK')),
              ElevatedButton(onPressed: _isAvailable, child: const Text('Amazon available?')),
              ElevatedButton(onPressed: _link, child: const Text('2. Link Amazon')),
              ElevatedButton(
                onPressed: () => _pay('wallet', {'method': 'wallet', 'wallet': 'amazonpay'}),
                child: const Text('3a. Pay wallet'),
              ),
              ElevatedButton(
                onPressed: () => _pay('paylater', {'method': 'paylater', 'provider': 'amazonpay'}),
                child: const Text('3b. Pay Later'),
              ),
            ]),
            const Divider(height: 32),
            ..._log.map((line) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: SelectableText(line, style: const TextStyle(fontFamily: 'Menlo', fontSize: 12)),
                )),
          ],
        ),
      ),
    );
  }
}
