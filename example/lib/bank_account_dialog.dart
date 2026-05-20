import 'package:flutter/material.dart';
import 'package:razorpay_flutter_customui/model/bank_account.dart';
import 'package:razorpay_flutter_customui/razorpay_flutter_customui.dart';

class BankAccountDialog extends StatelessWidget {
  final List<BankAccount> bankAccounts;
  final Razorpay razorpay;
  BankAccountDialog({
    required this.bankAccounts,
    required this.razorpay,
  });
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Please Select Bank Account ",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: bankAccounts.length,
                    itemBuilder: (context, index) {

                      return GestureDetector(
                        onTap: () {
                          razorpay.upiTurbo.selectedBankAccount(bankAccount: bankAccounts[index]);
                        },
                        child: ListTile(
                          title: Text(bankAccounts[index].maskedAccountNumber!),
                          subtitle: Text(bankAccounts[index].bank!.name!),
                          leading:
                          FadeInImage.assetNetwork(
                              placeholder: "images/bank_placeholder.png",
                              image:bankAccounts[index].bank!.logo!,
                          ),
                        ),
                      );
                    })),
          ],
        ),
      ),
    );
  }
}
