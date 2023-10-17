import 'package:flutter/material.dart';
import 'package:razorpay_flutter_customui/razorpay_flutter_customui.dart';
import 'package:razorpay_flutter_customui/model/tpv_bank_account.dart';

class TpvDialog extends StatefulWidget {

  final Razorpay razorpay;
  String? customerMobile;
  TpvDialog({ required this.customerMobile ,required this.razorpay,});

  @override
  State<TpvDialog> createState() => _TpvDialogState();
}

class _TpvDialogState extends State<TpvDialog> {
  String? orderId;

  String? accountNumber="";

  String? ifsc="";

  String? bankName="";

  String? customerId;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {


    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            Text("Turbo TPV UPI",style: TextStyle(fontSize: 18)),

            SizedBox(height: 20,),
            Flexible(
              child: TextField(
                keyboardType: TextInputType.text,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'CustomerId',
                ),
                onChanged: (newValue) =>
                customerId = newValue,
              ),
            ),
            Flexible(
              child: TextField(
                keyboardType: TextInputType.text,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'OrderId',
                ),
                onChanged: (newValue) =>
                orderId = newValue,
              ),
            ),
            SizedBox(height: 20,),
            Flexible(
              child: TextField(
                keyboardType: TextInputType.text,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'Account Number',
                ),
                onChanged: (newValue) =>
                accountNumber = newValue,
              ),
            ),
            SizedBox(height: 20,),
            Flexible(
              child: TextField(
                keyboardType: TextInputType.text,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'Ifsc code',
                ),
                onChanged: (newValue) =>
                ifsc = newValue,
              ),
            ),
            SizedBox(height: 20,),
            Flexible(
              child: TextField(
                keyboardType: TextInputType.text,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'Bank Name',
                ),
                onChanged: (newValue) =>
                bankName = newValue,
              ),
            ),
            SizedBox(height: 5,),
            isLoading
                ? CircularProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            )
                : SizedBox(height: 5,),

            ElevatedButton(onPressed: () {
              var tpvBankAccount = null;
              if(accountNumber!.isNotEmpty && bankName!.isNotEmpty && ifsc!.isNotEmpty){
                tpvBankAccount = TPVBankAccount(accountNumber: accountNumber, bankName:bankName , ifsc: ifsc );
              }
              widget.razorpay.tpv
                    .setOrderId(orderId)
                    .setCustomerId(customerId)
                    .setCustomerMobile(widget.customerMobile!)
                    .setTpvBankAccount(tpvBankAccount)
                    .linkNewUpiAccount();

              setState(() {
                isLoading = true;
              });


            }, child: Text('LinkNewUpiAccount TPV')),

            /*

            ElevatedButton(onPressed: () {
              if ((customerId  == '') || (customerId == null)) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Please enter customerId ")));
                return;
              }
              razorpay.tpv
                  .setCustomerId(customerId!)
                  .setCustomerMobile(customerMobile!)
                  .linkNewUpiAccount();

            }, child: Text('Only customer id')),

            ElevatedButton(onPressed: () {


              if ((orderId  == '') || (orderId == null)) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Please enter orderId ")));
                return;
              }

              if ( (accountNumber  == '') || (accountNumber == null)) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Please enter accountNumber ")));
                return;
              }

              if ( (bankName  == '') || (bankName == null)) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Please enter bankName ")));
                return;
              }

              if ( (ifsc  == '') || (ifsc == null)) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Please enter ifsc ")));
                return;
              }

              if ((customerId  == '') || (customerId == null)) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Please enter customerId ")));
                return;
              }

              var tPVBankAccount = TPVBankAccount(accountNumber: accountNumber, bankName:bankName , ifsc: ifsc );
              razorpay.tpv
                  .setOrderId(orderId)
                  .setTpvBankAccount(tPVBankAccount)
                  .setCustomerId(customerId!)
                  .setCustomerMobile(customerMobile!)
                  .linkNewUpiAccount();

            }, child: Text('OrderId & Bank Account')),



            ElevatedButton(onPressed: () {

              if ((orderId  == '') || (orderId == null)) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Please enter orderId ")));
                return;
              }
              if ((customerId  == '') || (customerId == null)) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Please enter customerId ")));
                return;
              }


              razorpay.tpv
                  .setOrderId(orderId)
                  .setCustomerId(customerId!)
                  .setCustomerMobile(customerMobile!)
                  .linkNewUpiAccount();

            }, child: Text('OrderId')),


            ElevatedButton(onPressed: () {

              if ( (accountNumber  == '') || (accountNumber == null)) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Please enter accountNumber ")));
                return;
              }

              if ( (bankName  == '') || (bankName == null)) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Please enter bankName ")));
                return;
              }

              if ( (ifsc  == '') || (ifsc == null)) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Please enter ifsc ")));
                return;
              }

              if ((customerId  == '') || (customerId == null)) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Please enter customerId ")));
                return;
              }


              //var tPVBankAccount = TPVBankAccount(accountNumber: "916010083473903", bankName:"axis" , ifsc:"AXIS0000003" );
              var tPVBankAccount = TPVBankAccount(accountNumber: accountNumber, bankName:bankName , ifsc: ifsc );
              razorpay.tpv
                  .setTpvBankAccount(tPVBankAccount)
                  .setCustomerId(customerId!)
                  .setCustomerMobile(customerMobile!)
                  .linkNewUpiAccount();

            }, child: Text('Bank Account')),
*/

          ],
        ),
      ),
    );
  }
}
