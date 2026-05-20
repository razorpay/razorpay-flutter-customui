class TPVBankAccount {

  String? account_number;
  String? ifsc;
  String? bank_name;

  TPVBankAccount({
    this.account_number,
    this.ifsc,
    this.bank_name,

  });

  factory TPVBankAccount.fromJson(Map<String, dynamic> json) => TPVBankAccount(
    account_number: json['account_number'],
    ifsc: json['ifsc'],
    bank_name: json['bank_name'],
  );

  Map<String, dynamic> toJson() => {
    'account_number': account_number,
    'ifsc': ifsc,
    'bank_name': bank_name,
  };
}
