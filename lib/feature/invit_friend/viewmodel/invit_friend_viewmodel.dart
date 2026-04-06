import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/invit_friend/models/referral_reward_model.dart';
import 'package:browny_applications_new/feature/invit_friend/repository/invit_friend_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class InvitFriendViewModel extends AppViewModel {
  InvitFriendViewModel({
    required super.context,
    required this.repo,
  });

  final InvitFriendDataSourceMixin repo;

  // ========== Dispose ==========
  @override
  void dispose() {
    _referralRewardNotifier.dispose();
    super.dispose();
  }

  // ========== ValueNotifier, Controller ==========
  final ValueNotifier<UiResult<ReferralRewardModel>> _referralRewardNotifier =
      ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<ReferralRewardModel>> get referralRewardNotifier =>
      _referralRewardNotifier;

  // ========== Logic ==========
  Future<void> fetchReferralRewardData() async {
    final result = await repo.fetchReferralReward(
      currentCustomerProvider.current.id,
    );
    if (result.hasError) {
      _referralRewardNotifier.value = UiResult.error(error: result.error);
      return;
    }

    if (result.isEmpty) {
      _referralRewardNotifier.value = UiResult.empty();
      return;
    }

    if (context.mounted) {
      _referralRewardNotifier.value = UiResult.success(
        data: ReferralRewardModel.fromResponse(
          result.data,
          Localizations.localeOf(context).languageCode,
        ),
      );
    }
  }

  String generateTextShare() {
    final phone = currentCustomerProvider.current.phone.orEmpty;
    String locale = Localizations.localeOf(context).languageCode;
    switch (locale) {
      case 'en':
        return '''
💚 Because I care, I'm telling you about Browny! 💚
Clean wash, fresh scent, soft fabric like new every time
Whether thick fabrics, thin fabrics, or your favorite clothes
— Browny handles it all 🧺✨

Just download the Browny app at http://brownypay.com/application and enter your friend's phone number $phone!
Order laundry through the app easily, track status at every step 💨

#BrownyLovesLaundry
''';
      case 'zh':
        return '''
💚 因为关心，所以推荐你使用 Browny！💚
洗得干净，香气扑鼻，每次都像新的一样柔软
无论是厚布料、薄布料，还是你最爱的衣服
— Browny 全部搞定 🧺✨

只需在 http://brownypay.com/application 下载 Browny 应用，并输入你朋友的电话号码 $phone！
通过应用轻松下单，随时跟踪每个步骤的状态 💨

#Browny爱洗衣
''';

      default:
        return '''
💚 เพราะรัก เลยบอกให้มาซักกับ Browny! 💚
ซักสะอาด หอมฟุ้ง ผ้านุ่มเหมือนใหม่ทุกครั้ง
ไม่ว่าจะผ้าหนา ผ้าบาง หรือผ้าสุดรัก
— Browny จัดการให้หมด 🧺✨

เพียงโหลดแอป Browny ได้เลยที่ http://brownypay.com/application และใส่เบอร์โทร $phone ของเพื่อนคุณ!
สั่งซักผ่านแอปง่าย ๆ ติดตามสถานะได้ทุกขั้นตอน 💨

#Brownyรักคนซักผ้า
''';
    }
  }
}
