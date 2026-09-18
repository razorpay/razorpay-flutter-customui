/// Apple Pay demo screen.
///
/// Two things this page exists to show:
///   1. `razorpay.applePay.canMakePayment()` — merchant-aware eligibility, which is
///      what a real integration gates its Apple Pay button on.
///   2. `razorpay.submit(...)` with an `app.apple_pay` block — the ordinary card
///      submit, routed to the Apple Pay sheet by the options alone. There is no
///      separate Apple Pay payment call.
///
/// Results arrive on the same EVENT_PAYMENT_SUCCESS / EVENT_PAYMENT_ERROR
/// listeners used for every other method, so a merchant already taking card
/// payments writes no new result handling.
///
/// The iOS Simulator cannot complete a payment: it has no Secure Element, so the
/// token carries no cryptogram and the backend returns `decryption_failed`. The
/// sheet still presents, which is enough to check wiring, but a real pass needs a
/// device with a card in Wallet.
import 'package:flutter/material.dart';
import 'package:razorpay_flutter_customui/razorpay_flutter_customui.dart';

class ApplePayPage extends StatefulWidget {
  const ApplePayPage({Key? key}) : super(key: key);

  @override
  State<ApplePayPage> createState() => _ApplePayPageState();
}

class _ApplePayPageState extends State<ApplePayPage> {
  // A merchant key with Apple Pay enabled. Only the key id belongs in a client
  // app; the API secret must never be embedded and is not needed for checkout.
  static const String keyId = 'rzp_live_L8cgyufqcbh6yX';

  // Must match the Apple Pay capability ticked in Xcode for this bundle id.
  static const String merchantIdentifier =
      'merchant.com.razorpay.applepay.ios.sandbox';

  late final Razorpay _razorpay;
  String _eligibility = 'checking...';
  bool _isPaying = false;
  final List<String> _log = <String>[];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.initilizeSDK(keyId);
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _checkEligibility('on open');
  }

  void _append(String line) {
    final String t = TimeOfDay.now().format(context);
    setState(() => _log.insert(0, '$t  $line'));
  }

  /// Eligibility depends on the merchant's preferences, which are fetched
  /// asynchronously, so a check made immediately after init can legitimately
  /// differ from one made a moment later. The re-check button is how that gets
  /// tested rather than assumed.
  Future<void> _checkEligibility(String label) async {
    try {
      final bool can = await _razorpay.applePay.canMakePayment();
      setState(() => _eligibility = can.toString());
      _append('canMakePayment() [$label] -> $can');
    } catch (e) {
      setState(() => _eligibility = 'error');
      _append('canMakePayment() [$label] threw: $e');
    }
  }

  void _onSuccess(dynamic response) {
    _append('SUCCESS ${response.data}');
    setState(() => _isPaying = false);
  }

  void _onError(dynamic response) {
    _append('ERROR ${response.data}');
    setState(() => _isPaying = false);
  }

  /// PassKit refuses to present a second sheet while one is pending, and a double
  /// tap returns SHEET_PRESENTATION_FAILED for both calls. The guard belongs in
  /// the merchant's UI — the native SDK behaves the same way.
  void _pay() {
    if (_isPaying) {
      _append('tap ignored - a payment is already in flight');
      return;
    }
    setState(() => _isPaying = true);

    final Map<String, dynamic> options = <String, dynamic>{
      'key': keyId,
      // Kept above roughly $2: smaller live amounts get caught by cross-border
      // risk checks and fail before authorization, which reads as an SDK failure
      // but is not one.
      'amount': '30000',
      'currency': 'INR',
      'description': 'Apple Pay example',
      'email': 'test@razorpay.com',
      'contact': '9999999999',
      'method': 'card',
      // country_code and label are deliberately absent. The SDK derives both -
      // country_code defaults to IN, and the sheet's merchant name comes from the
      // brand name already on file. Passing label risks showing the customer a
      // name inconsistent with the rest of the checkout.
      'app': <String, dynamic>{
        'name': 'apple_pay',
        'apple_pay': <String, dynamic>{
          'merchant_identifier': merchantIdentifier,
        },
      },
    };

    _append('submit() -> ${options['app']}');
    _razorpay.submit(options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apple Pay')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE6E9ED)),
                  bottom: BorderSide(color: Color(0xFFE6E9ED)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('canMakePayment()'),
                  Text(
                    _eligibility,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3395FF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => _checkEligibility('re-check'),
              child: const Text('Re-check canMakePayment'),
            ),
            const SizedBox(height: 12),
            // A real integration hides this button entirely when canMakePayment()
            // is false. It stays visible here so the negative case can be tested.
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _pay,
              child: Text(_isPaying ? 'Processing...' : 'Pay with Apple Pay'),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Log',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7684))),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _log.isEmpty
                        ? <Widget>[
                            const Text('nothing yet',
                                style: TextStyle(
                                    color: Color(0xFF9AA5B1), fontSize: 12))
                          ]
                        : _log
                            .map((String l) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(l,
                                      style: const TextStyle(
                                          fontSize: 11, fontFamily: 'Menlo')),
                                ))
                            .toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
