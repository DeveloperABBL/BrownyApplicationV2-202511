import 'package:json_annotation/json_annotation.dart';

part 'lucky_draw_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class LuckyDrawResponse {
  LuckyDrawResponse({
    this.type,
    this.status,
    this.step,
    this.reward,
    this.translations,
    this.message,
  });

  /// ประเภทผลลัพธ์: "won", "lose", "limit_reached", "scanned_today"
  @JsonKey(name: 'type')
  final String? type;

  /// ใช้ในกรณี error: "error"
  @JsonKey(name: 'status')
  final String? status;

  /// ลำดับขั้นตอน animation
  @JsonKey(name: 'step')
  final String? step;

  /// รางวัล (null เมื่อไม่ได้รับรางวัล หรือ type ไม่ใช่ "won")
  @JsonKey(name: 'reward', fromJson: _rewardFromJson, toJson: _rewardToJson)
  final LuckyDrawReward? reward;

  /// ข้อความแปลตาม locale — key คือ "th", "en", "zh"
  @JsonKey(name: 'translations')
  final Map<String, LuckyDrawTranslationData>? translations;

  /// ข้อความ error กรณี scanned_today หรือ invalid QR
  @JsonKey(name: 'message')
  final String? message;

  // ---------- Custom JSON helpers ----------

  static LuckyDrawReward? _rewardFromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      return LuckyDrawReward.fromJson(value);
    }
    return null;
  }

  static dynamic _rewardToJson(LuckyDrawReward? reward) =>
      reward?.toJson() ?? [];

  // ---------- Convenience getters ----------

  /// ได้รับรางวัล
  bool get isWon => type == 'won';

  /// ไม่ได้รับรางวัล
  bool get isLose => type == 'lose';

  /// รางวัลหมดแล้ว
  bool get isLimitReached => type == 'limit_reached';

  /// สแกนซ้ำในวันเดียว
  bool get isScannedToday => type == 'scanned_today';

  /// QR Code ไม่ถูกต้อง / error อื่นๆ
  bool get isError =>
      status == 'error' ||
      (!isWon && !isLose && !isLimitReached && !isScannedToday);

  String getTitleDisplay(String locale) {
    return getTranslation(locale)?.title ?? '-';
  }

  String getMessageDisplay(String locale) {
    return getTranslation(locale)?.message ?? '-';
  }

  String getBannerDisplay(String locale) {
    return getTranslation(locale)?.banner ?? '';
  }

  /// ดึง translation ตาม locale (fallback เป็น 'th')
  LuckyDrawTranslationData? getTranslation(String locale) {
    return translations?[locale] ?? translations?['th'];
  }

  factory LuckyDrawResponse.fromJson(Map<String, dynamic> json) =>
      _$LuckyDrawResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LuckyDrawResponseToJson(this);
}

@JsonSerializable()
class LuckyDrawReward {
  LuckyDrawReward({
    this.id,
    this.type,
    this.name,
  });

  @JsonKey(name: 'id')
  final int? id;

  /// ประเภทรางวัล เช่น "coupon"
  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'name')
  final String? name;

  factory LuckyDrawReward.fromJson(Map<String, dynamic> json) =>
      _$LuckyDrawRewardFromJson(json);
  Map<String, dynamic> toJson() => _$LuckyDrawRewardToJson(this);
}

@JsonSerializable()
class LuckyDrawTranslationData {
  LuckyDrawTranslationData({
    this.banner,
    this.title,
    this.message,
  });

  /// URL รูป banner สำหรับหน้าผลลัพธ์
  @JsonKey(name: 'banner')
  final String? banner;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'message')
  final String? message;

  factory LuckyDrawTranslationData.fromJson(Map<String, dynamic> json) =>
      _$LuckyDrawTranslationDataFromJson(json);
  Map<String, dynamic> toJson() => _$LuckyDrawTranslationDataToJson(this);
}
