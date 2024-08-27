import 'package:flutter/material.dart';
import 'package:razorpay_turbo/razorpay_turbo.dart';

class TurboUPITxnDialog extends StatefulWidget {

  final Razorpay razorpay;
  final String upiAccount;
  final String mobileNumber;
  final String sdkKey;
  TurboUPITxnDialog({required this.razorpay, required this.upiAccount , required this.mobileNumber ,
    required this.sdkKey});

  @override
  State<TurboUPITxnDialog> createState() => _TurboUPITxnDialogState();
}

class _TurboUPITxnDialogState extends State<TurboUPITxnDialog> {
  bool isLoading = false;
  var amount = 1000.0;
  var email = "";
  var orderId = "";
  @override
  void initState() {
    super.initState();
  }

  String validateFields() {
    if ((amount == '') || (amount == 0.0)) {
      return 'Please enter zero';
    }
    if (email == '' || email == null ) {
      return 'Enter email';
    }
    return '';
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
            SizedBox(height: 20,),

            Flexible(
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'Amount',
                ),
                onChanged: (newValue) =>
                amount = newValue as double,
              ),
            ),

            Flexible(
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'email',
                ),
                onChanged: (newValue) =>
                email = newValue ,
              ),
            ),

            Flexible(
              child: TextField(
                keyboardType: TextInputType.text,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'order id',
                ),
                onChanged: (newValue) =>
                orderId = newValue ,
              ),
            ),

            ElevatedButton(onPressed: () {

              var error = validateFields();
              if (error != '') {
                print(error);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(error)));
                return;
              }

              var payload;
              if(orderId.isNotEmpty){
                payload ={

                  "key":widget.sdkKey,
                  "currency": "INR",
                  "amount": amount,
                  "contact": widget.mobileNumber,
                  "method": "upi",
                  "email": email,
                  "upi": {
                    "flow": "in_app",
                    "type": "default"
                  },
                  "order_id" : orderId
                };
              }else {
                payload ={
                  "key":widget.sdkKey,
                  "currency": "INR",
                  "amount": amount,
                  "contact": widget.mobileNumber,
                  "method": "upi",
                  "email": email,
                  "upi": {
                    "flow": "in_app",
                    "type": "default"
                  }
                };
              }

              Map<String, dynamic> turboPayload = {
                "upiAccount": widget.upiAccount,
                "payload": payload,
              };

              widget.razorpay.submit(turboPayload);
              Navigator.of(context).pop();
              setState(() {
                isLoading = true;
              });

            }, child: Text('Pay')),
          ],
        ),
      ),
    );
  }
}
