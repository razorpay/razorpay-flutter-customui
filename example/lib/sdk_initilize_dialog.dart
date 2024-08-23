import 'package:flutter/material.dart';
import 'package:razorpay_turbo/razorpay_turbo.dart';
import 'package:razorpay_turbo/model/upi_account.dart';
import 'package:razorpay_turbo/card.dart' as RazorPayCard;
import 'package:razorpay_turbo/model/Error.dart';
import 'package:razorpay_turbo_example/payment_slection_page.dart';

class SDKInitilizeDialog extends StatelessWidget {
  String sdkKey ='rzp_test_0wFRWIZnH65uny';
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
                controller: TextEditingController()..text = 'rzp_test_0wFRWIZnH65uny',
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
