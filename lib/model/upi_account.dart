import 'bank_account.dart';

class UpiAccount {
  String? accountNumber;
  String? bankLogoUrl;
  String? bankName;
  String? bankId;
  String? bankPlaceholderUrl;
  String? ifsc;
  int? pinLength;
  Vpa? vpa;
  String? type;

  UpiAccount(
      {this.accountNumber,
      this.bankLogoUrl,
      this.bankName,
      this.bankId,
      this.bankPlaceholderUrl,
      this.ifsc,
      this.pinLength,
      this.vpa,
      this.type});

  factory UpiAccount.fromJson(Map<String, dynamic> json) => UpiAccount(
      accountNumber: json['account_number'],
      bankLogoUrl: json['bank_logo_url'],
      bankName: json['bank_name'],
      bankId: json['bank_id'],
      bankPlaceholderUrl: json['bankPlaceholderUrl'],
      ifsc: json['ifsc'],
      pinLength: json['pinLength'],
      vpa: Vpa.fromJson(json['vpa']),
      type: json['type']);

  Map<String, dynamic> toJson() => {
        'account_number': accountNumber,
        'bank_logo_url': bankLogoUrl,
        'bank_name': bankName,
        'bank_id': bankId,
        'bankPlaceholderUrl': bankPlaceholderUrl,
        'ifsc': ifsc,
        'pinLength': pinLength,
        'vpa': vpa?.toJson(),
        'type': type
      };
}

class Vpa {
  String? address;
  BankAccount? bankAccount;
  String? handle;
  bool? active;
  bool? isDefault;
  bool? validated;
  String? username;

  Vpa({
    this.address,
    this.bankAccount,
    this.handle,
    this.active,
    this.isDefault,
    this.validated,
    this.username,
  });

  factory Vpa.fromJson(Map<String, dynamic> json) => Vpa(
        address: json['address'],
        bankAccount: BankAccount.fromJson(json['bank_account']),
        handle: json['handle'],
        active: json['active'],
        isDefault: json['default'],
        validated: json['validated'],
        username: json['username'],
      );

  Map<String, dynamic> toJson() => {
        'address': address,
        'bank_account': bankAccount?.toJson(),
        'handle': handle,
        'active': active,
        'default': isDefault,
        'validated': validated,
        'username': username,
      };
}
