import 'package:flutter/material.dart';
import 'package:razorpay_flutter_customui/razorpay_flutter_customui.dart';
import 'package:razorpay_flutter_customui/model/upi_account.dart';
import 'package:razorpay_flutter_customui/card.dart' as RazorPayCard;
import 'package:razorpay_flutter_customui/model/Error.dart';

class CardDialog extends StatelessWidget {

  final UpiAccount? upiAccount;
  final Razorpay razorpay;
  
  String lastSixDigits ='';
  String expiryYear ='';
  String expiryMonth ='';
  
  CardDialog( {required this.upiAccount, required this.razorpay,});


  @override
  Widget build(BuildContext context) {
    String validateTurboUpiFields() {
      if ((lastSixDigits == '') ||
          (lastSixDigits == null)) {
        return 'Last Six digits cannot be Empty';
      }
      if ((expiryYear == '') ||
          (expiryYear == null)) {
        return 'Expiry Year Cannot be Empty';
      }
      if ((expiryMonth  == '') || (expiryMonth == null)) {
        return 'Expiry Month Cannot be Empty';
      }

      return '';
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            upiAccount == null ? Text("Setup UPI Pin",style: TextStyle(fontSize: 18),)
                : Text("Reset PIN",style: TextStyle(fontSize: 18),),
            SizedBox(height: 20,),
            Flexible(
              child: TextField(
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'Last Six digit of card',
                ),
                onChanged: (newValue) =>
                lastSixDigits = newValue,
              ),
            ),


            SizedBox(height: 16.0),
            Flexible(
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.start,
                maxLength: 2,
                decoration: InputDecoration(
                  hintText: 'Expiry Month',
                ),
                onChanged: (newValue) =>
                expiryMonth  = newValue,
              ),
            ),


            SizedBox(height: 16.0),
            Flexible(
              child: TextField(
                maxLength: 2,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'Expiry Year',
                ),
                onChanged: (newValue) =>
                expiryYear = newValue,
              ),
            ),

            SizedBox(height: 16.0),
            ElevatedButton(onPressed: () {

              var error = validateTurboUpiFields();
              if (error != '') {
                print(error);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(error)));
                return;
              }

              var card =  RazorPayCard.Card( lastSixDigits: lastSixDigits ,
                  expiryYear: expiryYear , expiryMonth: expiryMonth );

              if(upiAccount == null){
                razorpay.upiTurbo.setupUpiPin(card :card);
                return;
              }

              razorpay.upiTurbo.resetUpiPin(upiAccount : upiAccount!, card :card ,
                  onSuccess: (UpiAccount upiAccount){
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Rest UPI Pin done")));
                  },
                  onFailure: (Error error){
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error : ${error.errorDescription}")));
                  });
            }, child: Text('Rest UPI Pin')),

          ],
        ),
      ),
    );
  }
}
