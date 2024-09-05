import 'bank_account.dart';
import 'package:razorpay_turbo/model/upi_account.dart';

class PrefetchAccounts {
  List<dynamic>? accountsWithPinSet;
  List<BankAccount>? accountsWithPinNotSet;

  PrefetchAccounts([
    this.accountsWithPinSet,
    this.accountsWithPinNotSet
  ]);

  factory PrefetchAccounts.fromMap(Map<String, dynamic> response) {
    final List<dynamic> upiPinNotSetAccounts = response['accountsWithPinNotSet'];
    final List<dynamic> upiPinSetAccounts = response['accountsWithPinSet'];

    final bankAccounts = upiPinNotSetAccounts.map((account) => BankAccount.fromJson(account)).toList();
    final combinedAccount = upiPinSetAccounts.map( (pinSetAccount) {
      if (pinSetAccount['isUpiAccount']) {
        return UpiAccount.fromJson(pinSetAccount);
      } else {
        return BankAccount.fromJson(pinSetAccount);
      }
    }).toList();
    return PrefetchAccounts(combinedAccount, bankAccounts);
  }
}