import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter_customui/razorpay_flutter_customui.dart';
import 'package:razorpay_flutter_customui_example/models/card_info_model.dart';

enum PaymentMethods { card, upi, nb, wallet, vas }

class PaymentSelectionPage extends StatefulWidget {
  @override
  _PaymentSelectionPageState createState() => _PaymentSelectionPageState();
}

class _PaymentSelectionPageState extends State<PaymentSelectionPage> {
  String selectedPaymentType = 'CARD';
  PaymentMethods selectedMethod = PaymentMethods.card;
  CardInfoModel? cardInfoModel;
  String key = "rzp_test_1DP5mmOlF5G5ag";
  String? availableUpiApps;
  bool showUpiApps = false;

  //rzp_test_1DP5mmOlF5G5ag  ---> Debug Key
  //rzp_live_6KzMg861N1GUS8  ---> Live Key
  //rzp_live_cepk1crIu9VkJU  ---> Pay with Cred

  Map<String, dynamic>? netBankingOptions;
  Map<String, dynamic>? walletOptions;
  String? upiNumber;

  Map<dynamic, dynamic>? paymentMethods;
  List<NetBankingModel>? netBankingList;
  List<WalletModel>? walletsList;
  late Razorpay _razorpay;
  Map<String, dynamic>? commonPaymentOptions;

  @override
  void initState() {
    cardInfoModel = CardInfoModel();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.initilizeSDK(key);
    fetchAllPaymentMethods();

    netBankingOptions = {
      'key': key,
      'amount': 100,
      'currency': 'INR',
      'email': 'ramprasad179@gmail.com',
      'contact': '9663976539',
      'method': 'netbanking',
    };

    walletOptions = {
      'key': key,
      'amount': 100,
      'currency': 'INR',
      'email': 'ramprasad179@gmail.com',
      'contact': '9663976539',
      'method': 'wallet',
    };

    commonPaymentOptions = {};

    super.initState();
  }

  fetchAllPaymentMethods() {
    _razorpay.getPaymentMethods().then((value) {
      paymentMethods = value;
      configureNetbanking();
      configurePaymentWallets();
    }).onError((error, stackTrace) {
      print('Error Fetching payment methods: $error');
    });
  }

  configureNetbanking() {
    netBankingList = [];
    final nbDict = paymentMethods?['netbanking'];
    nbDict.entries.forEach(
      (element) {
        netBankingList?.add(
          NetBankingModel(bankKey: element.key, bankName: element.value),
        );
      },
    );
  }

  configurePaymentWallets() {
    walletsList = [];
    final walletsDict = paymentMethods?['wallet'];
    walletsDict.entries.forEach(
      (element) {
        if (element.value == true) {
          walletsList?.add(
            WalletModel(walletName: element.key),
          );
        }
      },
    );
  }

  void _handlePaymentSuccess(Map<dynamic, dynamic> response) {
    final snackBar = SnackBar(
      content: Text(
        'Payment Success : ${response.toString()}',
      ),
      action: SnackBarAction(
        label: 'Okay',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    print('Payment Success Response : $response');
  }

  void _handlePaymentError(Map<dynamic, dynamic> response) {
    final snackBar = SnackBar(
      content: Text(
        'Payment Error : ${response.toString()}',
      ),
      action: SnackBarAction(
        label: 'Okay',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    print('Payment Error Response : $response');
  }

  String validateCardFields() {
    if ((cardInfoModel?.cardNumber == '') ||
        (cardInfoModel?.cardNumber == null)) {
      return 'Card Number Cannot be Empty';
    }
    if ((cardInfoModel?.expiryMonth == '') ||
        (cardInfoModel?.expiryMonth == null)) {
      return 'Expiry Month / Year Cannot be Empty';
    }
    if ((cardInfoModel?.cvv == '') || (cardInfoModel?.cvv == null)) {
      return 'CVV Cannot be Empty';
    }
    if ((cardInfoModel?.mobileNumber == '') ||
        (cardInfoModel?.mobileNumber == null)) {
      return 'Mobile number cannot be Empty';
    }
    if ((cardInfoModel?.email == '') || (cardInfoModel?.email == null)) {
      return 'Email cannot be Empty';
    }
    return '';
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
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
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Selected Payment Type : $selectedPaymentType',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
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
    return ListView.builder(
      itemCount: walletsList?.length,
      itemBuilder: (context, item) {
        return ListTile(
          title: Text(walletsList?[item].walletName ?? ''),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            walletOptions?['wallet'] = walletsList?[item].walletName;
            if (walletOptions != null) {
              _razorpay.submit(walletOptions!);
            }
          },
        );
      },
    );
  }

  Widget buildBanksList() {
    return ListView.builder(
      itemCount: netBankingList?.length,
      itemBuilder: (context, item) {
        return ListTile(
          title: Text(netBankingList?[item].bankName ?? ''),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            netBankingOptions?['bank'] = netBankingList?[item].bankKey;
            if (netBankingOptions != null) {
              _razorpay.submit(netBankingOptions!);
            }
          },
        );
      },
    );
  }

  Widget buildUPIForm() {
    upiNumber = '';
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
                      onChanged: (value) {
                        upiNumber = value;
                      },
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
                    FocusScope.of(context).unfocus();
                    var options = {
                      'key': key,
                      'amount': 100,
                      'currency': 'INR',
                      'email': 'ramprasad179@gmail.com',
                      'contact': '9663976539',
                      'method': 'upi',
                      '_[flow]': 'intent',
                      'upi_app_package_name': 'paytm',
                    };
                    _razorpay.submit(options);
                  },
                  child: Text('Intent Flow')),
              ElevatedButton(
                  onPressed: () {
                    if ((upiNumber == null) || (upiNumber == '')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Plese Enter VPA'),
                        ),
                      );
                      return;
                    }

                    FocusScope.of(context).unfocus();
                    var options = {
                      'key': key,
                      'amount': 100,
                      'currency': 'INR',
                      'email': 'ramprasad179@gmail.com',
                      'contact': '9663976539',
                      'method': 'upi',
                      'vpa': upiNumber,
                      '_[flow]': 'collect',
                    };
                    _razorpay.submit(options);
                  },
                  child: Text('Collect Flow'))
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              final upiApps = await _razorpay.getAppsWhichSupportUpi();
              availableUpiApps = upiApps.toString();
              setState(() {
                showUpiApps = true;
              });
              print(upiApps);
            },
            child: Text('Get All UPI Supported Apps'),
          ),
          Visibility(
            visible: showUpiApps,
            child: Flexible(
              child: Text(availableUpiApps ?? ''),
            ),
          )
        ],
      ),
    );
  }

  Widget buildCardDetailsForm() {
    return Container(
      height: 200.0,
      child: SingleChildScrollView(
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
                        onChanged: (newValue) =>
                            cardInfoModel?.cardNumber = newValue,
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
                          onChanged: (newValue) {
                            final month = newValue.split('/').first;
                            final year = newValue.split('/').last;
                            cardInfoModel?.expiryYear = year;
                            cardInfoModel?.expiryMonth = month;
                          }),
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
                        onChanged: (newValue) => cardInfoModel?.cvv = newValue,
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
                        onChanged: (newValue) =>
                            cardInfoModel?.cardHolderName = newValue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Text('Phone :'),
                    SizedBox(width: 8.0),
                    Flexible(
                      child: TextField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'Mobile Number',
                        ),
                        onChanged: (newValue) =>
                            cardInfoModel?.mobileNumber = newValue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Text('Email :'),
                    SizedBox(width: 8.0),
                    Flexible(
                      child: TextField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'Email-ID',
                        ),
                        onChanged: (newValue) =>
                            cardInfoModel?.email = newValue,
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
                    var error = validateCardFields();
                    if (error != '') {
                      print(error);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(error)));
                      return;
                    }
                    var options = {
                      'key': key,
                      'amount': 100,
                      "card[cvv]": cardInfoModel?.cvv,
                      "card[expiry_month]": cardInfoModel?.expiryMonth,
                      "card[expiry_year]": cardInfoModel?.expiryYear,
                      "card[name]": cardInfoModel?.cardHolderName,
                      "card[number]": cardInfoModel?.cardNumber,
                      "contact": cardInfoModel?.mobileNumber,
                      "currency": "INR",
                      'email': cardInfoModel?.email,
                      'description': 'Fine T-Shirt',
                      "method": "card"
                    };
                    _razorpay.submit(options);
                  },
                  child: Text('Submit'),
                ),
                ElevatedButton(
                    onPressed: () async {
                      /* print('Pay With Cred Tapped');
                      final paymentMethods = await _razorpay.getPaymentMethods();
                      print('Payment Methods Retrievend: $paymentMethods'); */

                      var options = {
                        'key': key,
                        'amount': 100,
                        'currency': 'INR',
                        'email': 'ramprasad179@gmail.com',
                        'app_present': 0,
                        'contact': '9663976539',
                        'method': 'app',
                        'provider': 'cred',
                        // 'callback_url': 'flutterCustomUI://'
                      };
                      // _razorpay.submit(options);
                      // String logo = await _razorpay.getBankLogoUrl("UTIB");
                      // print(logo);
                      /* final isvalidVpa = await _razorpay.isValidVpa('9663976539@upi');
                      print(isvalidVpa); */

                      /* final supportedUpiApps =
                          await _razorpay.getAppsWhichSupportUpi();
                      print(supportedUpiApps); */

                      /* final cardNetwork =
                          await _razorpay.getCardsNetwork("4111111111111111");
                      print(cardNetwork); */

                      /* final walletLogo 
                          await _razorpay.getWalletLogoUrl('paytm');
                      print('Wallet URL : $walletLogo'); */

                      /* final length =
                          await _razorpay.getCardNetworkLength('VISA');
                      print(length); */
                    },
                    child: Text('Pay With Cred (Collect FLow)'))
              ],
            )
          ],
        ),
      ),
    );
  }
}

class PaymentTypeSelectionButton extends StatelessWidget {
  final String? paymentTitle;
  final VoidCallback? onPaymentTypeTap;

  PaymentTypeSelectionButton({
    this.paymentTitle,
    this.onPaymentTypeTap,
  });

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
