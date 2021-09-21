import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter_customui/razorpay_flutter_customui.dart';

enum PaymentMethods { card, upi, nb, wallet, vas }

class PaymentSelectionPage extends StatefulWidget {
  @override
  _PaymentSelectionPageState createState() => _PaymentSelectionPageState();
}

class _PaymentSelectionPageState extends State<PaymentSelectionPage> {
  String selectedPaymentType = 'CARD';
  PaymentMethods selectedMethod = PaymentMethods.card;
  RazorpayFlutterCustomui razorpayCustomUI;

  @override
  void initState() {
    razorpayCustomUI = RazorpayFlutterCustomui();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Payment Method'),
      ),
      backgroundColor: Colors.blue.shade300,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      PaymentTypeSelectionButton(
                        paymentTitle: 'CARD',
                        onPaymentTypeTap: () {
                          setState(() {
                            selectedPaymentType = 'CARD';
                            selectedMethod = PaymentMethods.card;
                          });
                        },
                      ),
                      PaymentTypeSelectionButton(
                        paymentTitle: 'UPI',
                        onPaymentTypeTap: () {
                          setState(() {
                            selectedPaymentType = 'UPI';
                            selectedMethod = PaymentMethods.upi;
                          });
                        },
                      ),
                      PaymentTypeSelectionButton(
                        paymentTitle: 'NET BANKING',
                        onPaymentTypeTap: () {
                          setState(() {
                            selectedPaymentType = 'NET BANKING';
                            selectedMethod = PaymentMethods.nb;
                          });
                        },
                      ),
                      PaymentTypeSelectionButton(
                        paymentTitle: 'WALLET',
                        onPaymentTypeTap: () {
                          setState(() {
                            selectedPaymentType = 'WALLET';
                            selectedMethod = PaymentMethods.wallet;
                          });
                        },
                      ),
                      PaymentTypeSelectionButton(
                        paymentTitle: 'VAS',
                        onPaymentTypeTap: () {
                          setState(() {
                            selectedPaymentType = 'VAS';
                            selectedMethod = PaymentMethods.vas;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.0),
                Expanded(
                  child: getReleventUI(),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Selected Payment Type : ${selectedPaymentType ?? ''}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getReleventUI() {
    switch (selectedMethod) {
      case PaymentMethods.card:
        return buildCardDetailsForm();
      case PaymentMethods.upi:
        return buildUPIForm();
      case PaymentMethods.nb:
        return buildBanksList();
      case PaymentMethods.wallet:
        return buildWalletsList();
      case PaymentMethods.vas:
        return buildForVas();
      default:
        return buildUPIForm();
    }
  }

  Widget buildForVas() {
    return Container(
      child: Column(
        children: [
          ElevatedButton(onPressed: () {}, child: Text('Make Payment')),
          ElevatedButton(
              onPressed: () {}, child: Text('Make Payment With Data'))
        ],
      ),
    );
  }

  Widget buildWalletsList() {
    return ListView(
      children: [
        ListTile(
          title: Text('mobikwik'),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {},
        ),
        ListTile(
          title: Text('payzapp'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('olamoney'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('airtelmoney'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('freecharge'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('phonepe'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('paypal'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
      ],
    );
  }

  Widget buildBanksList() {
    return ListView(
      children: [
        ListTile(
          title: Text('ICICI'),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {},
        ),
        ListTile(
          title: Text('SBI'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('Axis'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('HDFC'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('Corporation'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('CANARA'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('ICICI'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('SBI'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('Axis'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('HDFC'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('Corporation'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('CANARA'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('ICICI'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('SBI'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('Axis'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('HDFC'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('Corporation'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: Text('CANARA'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
      ],
    );
  }

  Widget buildUPIForm() {
    return Container(
      height: 200.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Text('VAP :'),
                  SizedBox(width: 8.0),
                  Flexible(
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'VPA',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(onPressed: () {}, child: Text('Intent Flow')),
              ElevatedButton(onPressed: () {}, child: Text('Collect Flow'))
            ],
          )
        ],
      ),
    );
  }

  Widget buildCardDetailsForm() {
    return Container(
      height: 200.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Text('Card Number :'),
                  SizedBox(width: 8.0),
                  Flexible(
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Card Number',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Text('Expiry :'),
                  SizedBox(width: 8.0),
                  Flexible(
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '12/23',
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Text('CVV'),
                  SizedBox(width: 8.0),
                  Flexible(
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '***',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Text('Name :'),
                  SizedBox(width: 8.0),
                  Flexible(
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Card Holder Name',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                  onPressed: () {
                    var options = {
                      'key': 'rzp_live_6KzMg861N1GUS8',
                      'amount': 100,
                      "card[cvv]": "123",
                      "card[expiry_month]": "11",
                      "card[expiry_year]": "23",
                      "card[name]": "Test User",
                      "card[number]": "4111111111111111",
                      "contact": "123456789",
                      "currency": "INR",
                      "display_logo": "0",
                      'email': 'test@razorpay.com',
                      'description': 'Fine T-Shirt',
                      "method": "card"
                    };
                    razorpayCustomUI.open(options);
                  },
                  child: Text('Submit')),
              ElevatedButton(
                  onPressed: () {}, child: Text('Pay With Cred (Collect FLow)'))
            ],
          )
        ],
      ),
    );
  }
}

class PaymentTypeSelectionButton extends StatelessWidget {
  final String paymentTitle;
  final VoidCallback onPaymentTypeTap;

  PaymentTypeSelectionButton({this.paymentTitle, this.onPaymentTypeTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPaymentTypeTap,
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(paymentTitle ?? ''),
        ),
      ),
    );
  }
}
