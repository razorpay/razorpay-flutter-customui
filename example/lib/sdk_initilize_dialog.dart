import 'package:flutter/material.dart';
import 'package:razorpay_turbo_example/payment_slection_page.dart';

class SDKInitilizeDialog extends StatelessWidget {
  String sdkKey ='rzp_test_8UzRYt0d70Ntgz';
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            Flexible(
              child: TextField(
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'MerchantKey',
                ),
                onChanged: (newValue) => sdkKey = newValue,
                controller: TextEditingController()..text = 'rzp_test_8UzRYt0d70Ntgz',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                if ((sdkKey == '') || (sdkKey == null)) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Please enter the key")));
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (builder) {
                      return PaymentSelectionPage( sdkKey);
                    },
                  ),
                );
              },
              child: Text('Initilize'),
            ),
          ],
        ),
      ),
    );
  }
}