import 'bank_model.dart';

class AllBanks {
  List<Bank>? popularBanks;
  List<Bank>? banks;

  AllBanks({this.popularBanks, this.banks});

  factory AllBanks.fromJson(Map<String, dynamic> json) {
    return AllBanks(
      popularBanks: (json['popularBanks'] as List<dynamic>?)
          ?.map((bankJson) => Bank.fromJson(bankJson))
          .toList(),
      banks: (json['banks'] as List<dynamic>?)
          ?.map((bankJson) => Bank.fromJson(bankJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (popularBanks != null) {
      data['popularBanks'] = popularBanks!.map((bank) => bank.toJson()).toList();
    }
    if (banks != null) {
      data['banks'] = banks!.map((bank) => bank.toJson()).toList();
    }
    return data;
  }
}
