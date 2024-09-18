import 'package:flutter/material.dart';
import 'package:razorpay_turbo/model/upi_account.dart';
import 'package:razorpay_turbo/razorpay_turbo.dart';
import 'package:razorpay_turbo/model/tpv_bank_account.dart';
import 'models/turbo_upi_model.dart';
import 'get_linked_upi_account_page.dart';

class TpvDialog extends StatefulWidget {
  final Razorpay razorpay;
  String? customerMobile;
  late String sdkKey;

  TpvDialog(
      {required this.customerMobile,
      required this.razorpay,
      required this.sdkKey});

  @override
  State<TpvDialog> createState() => _TpvDialogState();
}

class _TpvDialogState extends State<TpvDialog> {
  String? orderId;
  String? accountNumber = "";
  String? ifsc = "";
  String? bankName = "";
  String? customerId = "";
  TurboUPIModel? turboUPIModel;

  bool isLoading = false;
  late Razorpay _razorpay;
  String key = "";

  TextEditingController _controllerOrderId = new TextEditingController();
  TextEditingController _controllerCustomerId = new TextEditingController();
  TextEditingController _controllerAccountNumber = new TextEditingController();
  TextEditingController _controllerIFSC = new TextEditingController();
  TextEditingController _controllerBankName = new TextEditingController();

  @override
  void initState() {
    initValueForTurboUPI();

    key = widget.sdkKey;
    _razorpay = Razorpay(widget.sdkKey);

    widget.razorpay.on(Razorpay.EVENT_UPI_TURBO_LINK_NEW_UPI_TPV_ACCOUNT,
        _handleLinkNewTPVAccountReponse);
    print("SDK listener initialised");
    super.initState();
  }

  void _handleLinkNewTPVAccountReponse(dynamic response) {
    List<TPVBankAccount> tpvBankAccount = response["data"];
    setState(() {
      isLoading = false;
    });

    UpiAccount upiAccount = UpiAccount(
        accountNumber: tpvBankAccount[0].account_number,
        bankLogoUrl: "",
        bankName: tpvBankAccount[0].bank_name,
        bankPlaceholderUrl: "",
        ifsc: tpvBankAccount[0].ifsc,
        pinLength: 0,
        vpa: null,
        type: "");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (builder) {
          return GetLinkedUPIAccountPage(
              razorpay: _razorpay,
              upiAccounts: [upiAccount],
              keyValue: key,
              customerMobile: turboUPIModel!.mobileNumber.toString());
        },
      ),
    );
  }

  void initValueForTurboUPI() {
    _controllerOrderId.text = "";
    _controllerCustomerId.text = customerId!;
    _controllerAccountNumber.text = accountNumber!;
    _controllerIFSC.text = ifsc!;
    _controllerBankName.text = bankName!;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("Turbo TPV UPI", style: TextStyle(fontSize: 18)),
            SizedBox(
              height: 20,
            ),
            Flexible(
              child: TextField(
                controller: _controllerCustomerId,
                keyboardType: TextInputType.text,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'CustomerId',
                ),
                onChanged: (newValue) => customerId = newValue,
              ),
            ),
            Flexible(
              child: TextField(
                controller: _controllerOrderId,
                keyboardType: TextInputType.text,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'OrderId',
                ),
                onChanged: (newValue) => orderId = newValue,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Flexible(
              child: TextField(
                controller: _controllerAccountNumber,
                keyboardType: TextInputType.text,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'Account Number',
                ),
                onChanged: (newValue) => accountNumber = newValue,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Flexible(
              child: TextField(
                controller: _controllerIFSC,
                keyboardType: TextInputType.text,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'Ifsc code',
                ),
                onChanged: (newValue) => ifsc = newValue,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Flexible(
              child: TextField(
                controller: _controllerBankName,
                keyboardType: TextInputType.text,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'Bank Name',
                ),
                onChanged: (newValue) => bankName = newValue,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            isLoading
                ? CircularProgressIndicator(
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  )
                : SizedBox(
                    height: 5,
                  ),
            ElevatedButton(
                onPressed: () {
                  var tpvBankAccount = null;
                  if (accountNumber!.isNotEmpty &&
                      bankName!.isNotEmpty &&
                      ifsc!.isNotEmpty) {
                    tpvBankAccount = TPVBankAccount(
                        account_number: accountNumber,
                        bank_name: bankName,
                        ifsc: ifsc);
                  }
                  widget.razorpay.tpv
                      .setOrderId(orderId)
                      .setCustomerId(customerId)
                      .setCustomerMobile(widget.customerMobile!)
                      .setTpvBankAccount(tpvBankAccount)
                      .linkNewUpiAccountTPVWithUI();

                  setState(() {
                    isLoading = true;
                  });
                },
                child: Text('LinkNewUpiAccount TPV')),
          ],
        ),
      ),
    );
  }
}
