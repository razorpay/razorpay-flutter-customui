import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:razorpay_turbo/model/bank_account.dart';
import 'package:razorpay_turbo/model/upi_account.dart';
import 'package:razorpay_turbo/razorpay_turbo.dart';
import 'package:razorpay_turbo/model/prefetch_model.dart';
import 'package:razorpay_turbo/model/Error.dart';

class PrefetchAndLintNewAccounts extends StatefulWidget {
  final Razorpay razorpay;
  final String mobileNumber;

  const PrefetchAndLintNewAccounts(
      {required this.razorpay, required this.mobileNumber});

  @override
  State<PrefetchAndLintNewAccounts> createState() =>
      _PrefetchAndLinkScreenState();
}

class _PrefetchAndLinkScreenState extends State<PrefetchAndLintNewAccounts> {
  var pinSetAccounts = List.empty();
  var pinNotSetAccounts = List.empty();

  @override
  void initState() {
    widget.razorpay.upiTurbo
        .prefetchAndLinkUpiAccountsWithUI(customerMobile: widget.mobileNumber);
    widget.razorpay.on(
        Razorpay.EVENT_UPI_TURBO_PREFETCH_AND_LINK_NEW_UPI_ACCOUNT,
        _handleNewPrefetchAccountReponse);
    super.initState();
  }

  void _handleNewPrefetchAccountReponse(dynamic response) {
    PrefetchAccounts prefetchAccounts = response["data"];
    setState(() {
      pinSetAccounts = prefetchAccounts.accountsWithPinSet ?? [];
      pinNotSetAccounts = prefetchAccounts.accountsWithPinNotSet ?? [];
    });

    print(prefetchAccounts.accountsWithPinNotSet);
    print(prefetchAccounts.accountsWithPinSet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prefetch Accounts'),
      ),
      body: Column(
        children: [
          Text('Accounts with Pin Set'),
          Expanded(
            child: ListView.builder(
              itemCount: pinSetAccounts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(getName(pinSetAccounts[index])),
                  subtitle: Text(getAccountNumber(pinSetAccounts[index])),
                  trailing: getWidgetForState(pinSetAccounts[index]),
                );
              },
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Text('Accounts with Pin not Set'),
          Expanded(
            child: ListView.builder(
              itemCount: pinNotSetAccounts.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    widget.razorpay.upiTurbo.setUpiPinUI(
                      bankAccount: pinNotSetAccounts[index],
                      onSuccess: (List<UpiAccount> upiAccounts) {
                        setState(() {
                          pinSetAccounts.add(upiAccounts.first);
                          pinNotSetAccounts.removeAt(index);
                        });
                      },
                      onFailure: (Error error) {
                        print('Error Fetching payment methods: $error');
                      },
                    );
                  },
                  child: ListTile(
                    title: Text(pinNotSetAccounts[index].bank.name),
                    subtitle:
                        Text(pinNotSetAccounts[index].maskedAccountNumber),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  String getName(dynamic pinSetAccount) {
    if (pinSetAccount is BankAccount) {
      return pinSetAccount.bank?.name ?? '';
    } else if (pinSetAccount is UpiAccount) {
      return pinSetAccount.bankName ?? '';
    } else {
      return 'Unknown Name';
    }
  }

  String getAccountNumber(dynamic pinSetAccount) {
    if (pinSetAccount is BankAccount) {
      return pinSetAccount.maskedAccountNumber ?? '';
    } else if (pinSetAccount is UpiAccount) {
      return pinSetAccount.accountNumber ?? '';
    } else {
      return 'Unknown Name';
    }
  }

  Widget? getWidgetForState(dynamic pinSetAccounts) {
    final state = (pinSetAccounts as BankAccount).state ?? '';
    switch (state) {
      case 'linkingInProgress':
        return CircularProgressIndicator();
      case 'linkingSuccess':
        return Checkbox(value: true, onChanged: (bool? value) {});
      case 'linkingFailed':
        return Checkbox(
          activeColor: Color(0xFFFF0000),
          value: false,
          onChanged: (bool? value) {},
        );
      default:
        return null;
    }
  }
}
