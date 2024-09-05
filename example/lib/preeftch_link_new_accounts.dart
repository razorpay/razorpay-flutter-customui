import 'package:flutter/material.dart';
import 'package:razorpay_turbo/razorpay_turbo.dart';
import 'package:razorpay_turbo/model/prefetch_model.dart';

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

    pinSetAccounts = prefetchAccounts.accountsWithPinSet ?? [];
    pinNotSetAccounts = prefetchAccounts.accountsWithPinNotSet ?? [];

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
                  title: Text('Bank Name'),
                  subtitle: Text('Account Number : xxxxx7862'),
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
                return ListTile(
                  title: Text('Bank Name - PIN Not set'),
                  subtitle: Text('Account number : xxxx1234'),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
