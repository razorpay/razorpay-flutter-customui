class TPVBankAccount {

  String? accountNumber;
  String? ifsc;
  String? bankName;

  TPVBankAccount({
    this.accountNumber,
    this.ifsc,
    this.bankName,

  });

  factory TPVBankAccount.fromJson(Map<String, dynamic> json) => TPVBankAccount(
    accountNumber: json['accountNumber'],
    ifsc: json['ifsc'],
    bankName: json['bankName'],
  );

  Map<String, dynamic> toJson() => {
    'accountNumber': accountNumber,
    'ifsc': ifsc,
    'bankName': bankName,
  };
}
