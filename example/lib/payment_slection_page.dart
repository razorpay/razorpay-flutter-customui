import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter_customui/razorpay_flutter_customui.dart';
import 'package:razorpay_flutter_customui_example/models/card_info_model.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter_customui_example/tpv_dialog.dart';
import 'bank_account_dialog.dart';
import 'bank_list_screen_page.dart';
import 'card_dialog.dart';
import 'models/turbo_upi_model.dart';
import 'package:razorpay_flutter_customui/model/upi_account.dart';
import 'get_linked_upi_account_page.dart';

import 'sim_dialog.dart';
import 'package:razorpay_flutter_customui/model/Error.dart';

enum PaymentMethods { card, upi, nb, wallet, vas, turboUPI }

class PaymentSelectionPage extends StatefulWidget {

  
  late String sdkKey;
  PaymentSelectionPage( String sdkKey){
    this.sdkKey = sdkKey;
  }

  @override
  _PaymentSelectionPageState createState() => _PaymentSelectionPageState();
}

class _PaymentSelectionPageState extends State<PaymentSelectionPage> {

  String selectedPaymentType = 'CARD';
  PaymentMethods selectedMethod = PaymentMethods.card;
  CardInfoModel? cardInfoModel;
  String key ="" ; //

  String? availableUpiApps;
  bool showUpiApps = false;
  TurboUPIModel? turboUPIModel;

  //rzp_test_1DP5mmOlF5G5ag  ---> Debug Key
  //rzp_live_6KzMg861N1GUS8  ---> Live Key
  //rzp_live_cepk1crIu9VkJU  ---> Pay with Cred

  Map<String, dynamic>? netBankingOptions;
  Map<String, dynamic>? walletOptions;
  String? upiNumber;

  Map<dynamic, dynamic>? paymentMethods;
  List<NetBankingModel>? netBankingList;
  List<WalletModel>? walletsList;
 
  Map<String, dynamic>? commonPaymentOptions;
  TextEditingController _controllerMerchantKey = new TextEditingController();
  TextEditingController _controllerHandle = new TextEditingController();
  TextEditingController _controllerMobile = new TextEditingController();

  final int _CODE_EVENT_SUCCESS = 200;
  final int _CODE_EVENT_ERROR = 201;
  bool isLoading = false;

  // For Turbo UPI
  String turboUpiHandle = 'axisbank';
  String mobileNo = "";
  late Razorpay _razorpay;

  @override
  void initState() {
    cardInfoModel = CardInfoModel();
    turboUPIModel = TurboUPIModel();
    initValueForTurboUPI();
    key = widget.sdkKey;
    _razorpay = Razorpay(widget.sdkKey);
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_UPI_TURBO_LINK_NEW_UPI_ACCOUNT, _handleNewUpiAccountResponse);
    fetchAllPaymentMethods();
    print("=====> key ${key} ");
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


  void handleCallback(String result) {
    print('Callback result: $result');
  }


  void initValueForTurboUPI(){
    _controllerMerchantKey.text = key;
    _controllerHandle.text = turboUpiHandle;
    turboUPIModel?.handle = turboUpiHandle ;
    _controllerMobile.text = mobileNo;
    turboUPIModel?.mobileNumber = mobileNo;

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

  // UPI Turbo
  void _handleNewUpiAccountResponse(dynamic response) {
    print("_handleNewUpiAccountResponse() response : ${response} ");

    if (response["error"] != null ) {
      Error error = response["error"];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Action : ${response["action"]}\nError Code : ${error.errorCode} Error Description : ${error.errorDescription}")));
      setState(() {isLoading = false;});
      return;
    }

    switch (response["action"]) {
      case "ASK_FOR_PERMISSION":
        print("ASK_FOR_PERMISSION called");
        setState(() {
          isLoading = false;
        });
        _razorpay.upiTurbo.askForPermission();
        break;
      case "LOADER_DATA":
        print("LOADER_DATA called");
        setState(() {
          isLoading = true;
        });
        break;
      case "STATUS":
        print("STATUS called ${response[""]}");
        setState(() {
          isLoading = false;
        });
      /*
          if status have no error then in response["data"] upiAccounts will return .
          merchant can use this response["data"] upiAccounts or can again call
          _razorpay.getLinkedUpiAccounts(turboUPIModel?.mobileNumber)
       */
        Navigator.pop(context);
        getLinkedUpiAccounts();
        break;
      case "SELECT_SIM":
        print("SELECT_SIM called data :  ${response["data"]}");
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimDialog(
              sims: response["data"],
              razorpay: _razorpay,
            );
          },
        );
        break;
      case "SELECT_BANK":
        setState(() {
          isLoading = false;
        });
        print("SELECT_BANK called data :  ${response["data"]}");
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                BankListScreen(razorpay: _razorpay, allbanks: response["data"]),
          ),
        );
        break;
      case "SELECT_BANK_ACCOUNT":
        setState(() {
          isLoading = false;
        });
        print("SELECT_BANK_ACCOUNT called data :  ${response["data"]}");
        var bankAccounts = response["data"];
        if (bankAccounts.isEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("No Account Found")));
          return;
        }
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return BankAccountDialog(
              bankAccounts: bankAccounts,
              razorpay: _razorpay,
            );
          },
        );
        break;
      case "SETUP_UPI_PIN":
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CardDialog(
              upiAccount: null,
              razorpay: _razorpay,
            );
          },
        );
        break;
      default:
        print('Wrong action :  ${response["action"]}');
    }
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

  String validateTurboUpiFields() {

    if ((turboUPIModel?.handle == '') || (turboUPIModel?.handle == null)) {
      return 'Handle Cannot be Empty';
    }
    if ((turboUPIModel?.mobileNumber == '') ||
        (turboUPIModel?.mobileNumber == null)) {
      return 'Mobile Number Cannot be Empty';
    }

    return '';
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
    _controllerHandle.dispose();
    _controllerMerchantKey.dispose();
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
                      PaymentTypeSelectionButton(
                        paymentTitle: 'TURBO UPI',
                        onPaymentTypeTap: () {
                          setState(() {
                            selectedPaymentType = 'TURBO_UPI';
                            selectedMethod = PaymentMethods.turboUPI;
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
      case PaymentMethods.turboUPI:
        return buildForTurboUPI();
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

  // MerchantKey
  // Handle
  // Mobile Number
  Widget buildForTurboUPI() {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: Column(
        children: [

          SizedBox(height: 16.0),
          Flexible(
            child: TextField(
              controller: _controllerHandle,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                hintText: 'Handle',
              ),
              onChanged: (newValue) => turboUPIModel?.handle = newValue,
            ),
          ),
          SizedBox(height: 16.0),
          Flexible(
            child: TextField(
              controller: _controllerMobile ,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                hintText: 'Mobile Number',
              ),
              onChanged: (newValue) => turboUPIModel?.mobileNumber = newValue,
            ),
          ),
          SizedBox(height: 6.0),
          isLoading
              ? CircularProgressIndicator(
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                )
              : SizedBox(height: 2,),
          ElevatedButton(
                  onPressed: () {
                    var error = validateTurboUpiFields();
                    if (error != '') {
                      print(error);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(error)));
                      return;
                    }
                      _razorpay.upiTurbo.linkNewUpiAccount(
                          customerMobile: turboUPIModel?.mobileNumber);
                  },
                  child: Text('LinkNewUpiAccount')),
          SizedBox(height: 6.0),
          ElevatedButton(
              onPressed: () {
                var error = validateTurboUpiFields();
                if (error != '') {
                  print(error);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error)));
                  return;
                }
                setState(() {
                  isLoading = true;
                });
                getLinkedUpiAccounts();
              },
              child: Text('GetLinkedUpiAccounts')),
          SizedBox(height: 8.0),
          ElevatedButton(
              onPressed: () {
                var error = validateTurboUpiFields();
                if (error != '') {
                  print(error);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error)));
                  return;
                }
                setState(() {
                  isLoading = true;
                });
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return TpvDialog(
                      customerMobile : turboUPIModel!.mobileNumber,
                      razorpay: _razorpay,
                    );
                  },
                );
              },
              child: Text('TurboViaTPV')),
          SizedBox(height: 8.0),
          ElevatedButton(
              onPressed: () {
                var error = validateTurboUpiFields();
                if (error != '') {
                  print(error);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error)));
                  return;
                }
                setState(() {
                  isLoading = true;
                });

                _razorpay.upiTurbo.linkNewUpiAccountWithUI(
                    customerMobile: turboUPIModel?.mobileNumber, color: "#000000",
                    onSuccess: (List<UpiAccount> upiAccounts) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) {
                            return GetLinkedUPIAccountPage(
                                razorpay: _razorpay, upiAccounts: upiAccounts , keyValue :key, customerMobile: turboUPIModel!.mobileNumber!!);
                          },
                        ),
                      );
                    },
                    onFailure: (Error error) { ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error : ${error.errorDescription}")));});

              },
              child: Text('LinkNewUpiAccount_UI')),
          SizedBox(height: 4.0),
          ElevatedButton(
              onPressed: () {
                var error = validateTurboUpiFields();
                if (error != '') {
                  print(error);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error)));
                  return;
                }
                setState(() {
                  isLoading = true;
                });

                _razorpay.upiTurbo.manageUpiAccounts(
                    customerMobile: turboUPIModel?.mobileNumber,
                    onFailure: (Error error) {  });

              },
              child: Text('ManageUpiAccounts_UI')),
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


  void getLinkedUpiAccounts() {
    print("getLinkedUpiAccounts()");
    _razorpay.upiTurbo.getLinkedUpiAccounts(
        customerMobile: turboUPIModel?.mobileNumber,
        onSuccess: (List<UpiAccount> upiAccounts){
          print("onSuccess() upiAccounts");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) {
                return GetLinkedUPIAccountPage(
                    razorpay: _razorpay,
                    upiAccounts: upiAccounts ,
                    keyValue : key,
                    customerMobile : turboUPIModel!.mobileNumber.toString()
                );
              },
            ),
          );
        },
        onFailure: (Error error) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error : ${error.errorDescription}")));
        });
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
