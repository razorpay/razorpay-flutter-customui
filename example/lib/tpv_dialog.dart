import 'package:flutter/material.dart';
import 'package:razorpay_turbo/razorpay_turbo.dart';
import 'package:razorpay_turbo/model/tpv_bank_account.dart';

class TpvDialog extends StatefulWidget {
  final Razorpay razorpay;
  String? customerMobile;
  TpvDialog({
    required this.customerMobile,
    required this.razorpay,
  });

  @override
  State<TpvDialog> createState() => _TpvDialogState();
}

class _TpvDialogState extends State<TpvDialog> {
  String? orderId;
  String? accountNumber = "";
  String? ifsc = "";
  String? bankName = "";
  String? customerId = "";

  bool isLoading = false;

  TextEditingController _controllerOrderId = new TextEditingController();
  TextEditingController _controllerCustomerId = new TextEditingController();
  TextEditingController _controllerAccountNumber = new TextEditingController();
  TextEditingController _controllerIFSC = new TextEditingController();
  TextEditingController _controllerBankName = new TextEditingController();

  @override
  void initState() {
    initValueForTurboUPI();
    super.initState();
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
                      .linkNewUpiAccount();

                  setState(() {
                     Navigator.pop(context);
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
