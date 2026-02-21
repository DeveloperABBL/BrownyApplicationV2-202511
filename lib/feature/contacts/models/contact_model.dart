import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';

enum ContactType {
  link,
  call,
}

enum ContactProvider {
  problemLink(key: 'problem_link'),
  facebookLink(key: 'facebook_link'),
  lineLink(key: 'Line_link'),
  youtubeLink(key: 'youtube_link'),
  tiktokLink(key: 'tiktok_link'),
  registerTermsLink(key: 'register_terms_link'),
  brownyCareContact(key: 'browny_care_contact');

  final String key;
  // Const constructor
  const ContactProvider({
    required this.key,
  });
  // function checkname
  bool equalsName(String source) => key == source;

  /// default filter สำหรับหน้าแจ้งปัญหา
  static List<ContactProvider> get helpAndProblemNoti => [
    brownyCareContact,
    lineLink,
  ];

  /// default filter สำหรับหน้าสมัคร
  static List<ContactProvider> get registerTerms => [
    registerTermsLink,
  ];

  /// default filter สำหรับหน้าสมัคร
  static List<ContactProvider> get contacts => [
    problemLink,
    facebookLink,
    lineLink,
    youtubeLink,
    tiktokLink,
    brownyCareContact,
  ];

  String getNameDisplay(String locale) {
    switch (this) {
      case ContactProvider.problemLink:
        return ContentLocalizeData(
          en: 'Contact Problem',
          zh: '联系问题',
          th: 'ติดต่อแจ้งปัญหา',
        ).getByLocaleCode(locale)!;
      case ContactProvider.facebookLink:
        return ContentLocalizeData(
          th: 'Facebook',
        ).getByLocaleCode(locale)!;

      case ContactProvider.lineLink:
        return ContentLocalizeData(
          en: 'Inquiry via LINE Browny Official',
          zh: '通过 LINE 布朗尼官方咨询',
          th: 'สอบถามผ่าน LINE Browny Official',
        ).getByLocaleCode(locale)!;

      case ContactProvider.youtubeLink:
        return ContentLocalizeData(
          th: 'Youtube',
        ).getByLocaleCode(locale)!;

      case ContactProvider.tiktokLink:
        return ContentLocalizeData(
          th: 'TikTok',
        ).getByLocaleCode(locale)!;

      case ContactProvider.registerTermsLink:
        return ContentLocalizeData(
          en: 'Terms of Service and Privacy Policy',
          zh: '服务条款和隐私政策',
          th: 'เงื่อนไขการใช้บริการและนโยบายความเป็นส่วนตัว',
        ).getByLocaleCode(locale)!;

      case ContactProvider.brownyCareContact:
        return ContentLocalizeData(
          en: 'Contact Browny Care',
          zh: '联系Browny Care',
          th: 'ติดต่อ Browny Care',
        ).getByLocaleCode(locale)!;
    }
  }
}

class ContactModel {
  final String data;
  final ContactType type;
  final ContactProvider provider;

  ContactModel({
    required this.data,
    required this.type,
    required this.provider,
  });

  ContactModel copyWith(ContactModel newObject) {
    return ContactModel(
      data: newObject.data,
      type: newObject.type,
      provider: newObject.provider,
    );
  }
}
