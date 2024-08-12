import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter_customui_turbo/model/account_balance.dart';
import 'package:razorpay_flutter_customui_turbo/model/empty.dart';
import 'package:razorpay_flutter_customui_turbo/model/upi_account.dart';
import 'package:razorpay_flutter_customui_turbo/razorpay_flutter_customui_turbo.dart';
import 'package:razorpay_flutter_customui_turbo_example/turbo_upi_txn_dialog.dart';
import 'card_dialog.dart';
import 'package:razorpay_flutter_customui_turbo/model/Error.dart';

class GetLinkedUPIAccountPage extends StatelessWidget {
  final List<UpiAccount> upiAccounts;
  final Razorpay razorpay;
  final String  keyValue;
  final String customerMobile;

  const GetLinkedUPIAccountPage({
    required this.upiAccounts,
    required this.razorpay,
    required this.keyValue,
    required this.customerMobile
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Turbo UPI'),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: ListView.builder(
              itemCount: upiAccounts.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(10.0),
                  margin: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Bank Name : ${upiAccounts[index].bankName}", style: TextStyle(fontSize: 18, color: Colors.white)),
                      Text("Account Number : ${upiAccounts[index].accountNumber}", style: TextStyle(fontSize: 18, color: Colors.white)),
                      Text("VPA : ${upiAccounts[index].vpa?.address}",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                      SizedBox(
                        height: 15,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return TurboUPITxnDialog(
                                  razorpay: razorpay,
                                  upiAccount : getUpiAccountStr(upiAccounts[index]),
                                  mobileNumber: customerMobile,
                                  sdkKey: keyValue,
                                );
                              },
                            );
                          },
                          child: Text('Pay Rs 1.00')),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                razorpay.upiTurbo.getBalance(
                                    upiAccount: upiAccounts[index],
                                    onSuccess: (AccountBalance accountBalance){
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(" Balance : Rs ${accountBalance.balance}")));
                                    },
                                    onFailure: (Error error){
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Error : ${error.errorDescription}")));
                                    } );
                              },
                              child: Text('Get Balance')),
                          ElevatedButton(
                              onPressed: () {
                                razorpay.upiTurbo.changeUpiPin(upiAccount: upiAccounts[index],
                                    onSuccess: (UpiAccount upiAccount){
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Upi Pin Changed")));
                                    },
                                    onFailure: (Error error){
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Error : ${error.errorDescription}")));
                                    });
                              },
                              child: Text('Change UPI Pin Done')),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CardDialog(
                                      upiAccount : upiAccounts[index],
                                      razorpay: razorpay,
                                    );
                                  },
                                );
                              },
                              child: Text('Reset PIN')),
                          ElevatedButton(
                              onPressed: () {
                                razorpay.upiTurbo.delink(upiAccount: upiAccounts[index],
                                    onSuccess: (Empty empty){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("DeLink Done")));
                                },
                                onFailure: (Error error){
                                ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error : ${error.errorDescription}")));
                                });
                              },
                              child: Text('DeLink')),
                        ],
                      )
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }

  String getUpiAccountStr(UpiAccount upiAccount){
    return jsonEncode( UpiAccount(accountNumber: upiAccount.accountNumber,
        bankLogoUrl: upiAccount.bankLogoUrl, bankName: upiAccount.bankName,
        bankPlaceholderUrl: upiAccount.bankPlaceholderUrl, ifsc: upiAccount.ifsc,
        pinLength: upiAccount.pinLength, vpa: upiAccount.vpa).toJson());
  }
}
