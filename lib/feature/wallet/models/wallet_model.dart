import 'package:browny_applications_new/core/data/remote/models/response/customer_profile_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';

class WalletModel extends CustomerProfileData {
  @override
  String get creditBalance => super.creditBalance.ifNullOrEmpty('0.0');

  List<int> amountBadge = [];
  int _selectedAmount = -1;

  /// กันได้ -1 จาก [List.indexOf]
  int get selectedAmount => _selectedAmount;

  WalletModel._fromCustomerProfileData(CustomerProfileData data)
    : super(
        id: data.id,
        name: data.name,
        email: data.email,
        phone: data.phone,
        creditBalance: data.creditBalance,
        image: data.image,
      );

  @override
  WalletModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? birthday,
    String? image,
    String? creditBalance,
    String? brownyCoin,
    List<String>? avatars,
    List<int>? amountBadge,
    int? selectedAmount,
  }) {
    return WalletModel._fromCustomerProfileData(
        CustomerProfileData(
          id: id ?? this.id,
          name: name ?? this.name,
          email: email ?? this.email,
          phone: phone ?? this.phone,
          creditBalance: creditBalance ?? super.creditBalance,
          image: image ?? this.image,
        ),
      )
      ..amountBadge = amountBadge ?? this.amountBadge
      .._selectedAmount = selectedAmount ?? _selectedAmount;
  }

  factory WalletModel.fromCustomerProfileData(CustomerProfileData data) {
    return WalletModel._fromCustomerProfileData(data);
  }
}
