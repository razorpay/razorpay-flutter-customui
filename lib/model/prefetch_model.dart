import 'bank_account.dart';

class PrefetchAccounts {
  List<dynamic>? accountsWithPinSet;
  List<BankAccount>? accountsWithPinNotSet;

  PrefetchAccounts([
    this.accountsWithPinSet,
    this.accountsWithPinNotSet
  ]);

  factory PrefetchAccounts.fromMap(Map<String, dynamic> response) {
    final List<dynamic> upiPinNotSetAccounts = response['accountsWithPinNotSet'];
    final List<Map<String, dynamic>> upiPinSetAccounts = response['accountsWithPinSet'];

    final bankAccounts = upiPinNotSetAccounts.map((account) => BankAccount.fromJson(account)).toList();
    final pinNotSetAccount = upiPinSetAccounts.map( (pinSetAccount) {

    });
    //bankListJson.map((json) => Bank.fromJson(json)).toList();
  }
}