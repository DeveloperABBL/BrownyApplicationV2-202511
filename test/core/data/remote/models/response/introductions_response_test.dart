import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:browny_applications_new/core/data/remote/models/response/introductions_response.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  const rawJson = '''
[
    {
        "image_url": "https://dev.abgroup.co.th/storage/intro_images/J7ozTOOXuwsKei6CF2uiDkOdLo5jl1C8qWtKaZXz.png",
        "title": {
            "th": "ใช้ง่ายจ่ายสะดวก",
            "en": "Cashless Convenience",
            "zh": "使用方便，支付便捷"
        },
        "subtitle": {
            "th": "<p>รองรับ 6 ช่องทางการชำระเงินออนไลน์ อาทิ พร้อมเพย์,</p><p>TP+ Wallet, TrueMoney, WeChat Pay, ShopeePay และ Rabbit LINE Pay</p>",
            "en": "<p>Experience up to 6 cashless ways to pay at Browny: PromptPay,&nbsp;</p><p>TP+ Wallet, TrueMoney, WeChat Pay, ShopeePay, Rabbit LINE Pay.</p>",
            "zh": "<p>支持6种线上支付方式，包括PromptPay、TP+ Wallet、TrueMoney、微信支付、ShopeePay 和 Rabbit LINE Pay。<br>&nbsp;</p>"
        }
    },
    {
        "image_url": "https://dev.abgroup.co.th/storage/intro_images/GHi2BGYBAJV6y5wFL1WqkmQJQHBZRye7GP204YwJ.png",
        "title": {
            "th": "สะสมแต้มกับ Browny Club",
            "en": "Earn points with Browny Club",
            "zh": "加入 Browny Club 累积积分"
        },
        "subtitle": {
            "th": "<p>สะสมเสต็ปในทุกการซักอบ เพื่อรับฟรี คูปองส่วนลดเงินสดหรือสิทธิ์แลกซื้อสินค้า Browny อีกมากมาย</p>",
            "en": "<p>Collect steps every time you do laundry and drying to receive free cash discount coupons or exclusive deals on Browny products.<br>&nbsp;</p>",
            "zh": "<p>每次洗烘衣都能累积积分，免费兑换现金折扣券或 Browny 商品的专属优惠！<br>&nbsp;</p>"
        }
    },
    {
        "image_url": "https://dev.abgroup.co.th/storage/intro_images/AmodVE7jnzALqHYCRSFzU290CDkQ2zOBjMSjcl8W.png",
        "title": {
            "th": "คุ้มทุกการซักอบด้วย E-Voucher",
            "en": "Save on every laundry session with E-Voucher",
            "zh": "使用 E-Voucher，洗烘更超值"
        },
        "subtitle": {
            "th": "<p>E-Voucher ให้คุณซักอบผ้าในราคาสุดคุ้มแบบเหมาๆ โดยการซื้อคูปองราคาพิเศษเก็บไว้ใช้ในภายหลังได้ เพื่อรับส่วนลดสูงสุดกว่า 50%<br>&nbsp;</p>",
            "en": "<p>E-Vouchers let you wash and dry at great value prices by purchasing special-priced coupons in advance — enjoy up to 50% off!<br>&nbsp;</p>",
            "zh": "<p>购买特价 E-Voucher 预留使用，享受洗烘服务高达 50% 的优惠，省钱又方便！<br>&nbsp;</p>"
        }
    }
]
''';

  group('IntroductionsResponse parsing', () {
    test('DateTime', () async {
      await initializeDateFormatting();
      var dateFromat = DateFormat(
        'dd-MM-yyyy / HH:mm',
        'zh',
      ).parse('9-06-2025 / 14:30');
      // final dateTime = DateTime.parse('10-06-2025 / 14:30');
      dateFromat = dateFromat.copyWith(year: dateFromat.year + 543);
      // dateTimeSymbolMap()['th'];
      final formater = DateFormat(
        'dd MMM yy HH:mm น.',
        'zh',
      ).format(dateFromat);

      print(formater);
      print(dateFromat);
    });

    test('parses raw array JSON into List<IntroductionsResponse>', () {
      final List<dynamic> list = jsonDecode(rawJson) as List<dynamic>;
      final items = list
          .map((e) => IntroductionsResponse.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(items.length, 3);

      final first = items.first;
      expect(
        first.imageUrl,
        'https://dev.abgroup.co.th/storage/intro_images/J7ozTOOXuwsKei6CF2uiDkOdLo5jl1C8qWtKaZXz.png',
      );
      expect(first.title?.th, 'ใช้ง่ายจ่ายสะดวก');
      expect(first.title?.en, 'Cashless Convenience');
      expect(
        first.subtitle?.en,
        contains('Experience up to 6 cashless ways to pay at Browny'),
      );
      expect(first.subtitle?.th, contains('<p>'));

      // BaseModelResponse default fields
      expect(first.success, isFalse);
      expect(first.message, isNull);
      expect(first.errorType, isNull);
    });

    test('toJson round-trip preserves core fields', () {
      final List<dynamic> list = jsonDecode(rawJson) as List<dynamic>;
      final firstJson = list.first as Map<String, dynamic>;

      final model = IntroductionsResponse.fromJson(firstJson);
      final encoded = model.toJson();
      final decoded = IntroductionsResponse.fromJson(encoded);

      expect(decoded.imageUrl, model.imageUrl);
      expect(decoded.title?.th, model.title?.th);
      expect(decoded.title?.en, model.title?.en);
      expect(decoded.subtitle?.zh, contains('微信'));
    });

    test('handles missing optional fields gracefully', () {
      final minimal = <String, dynamic>{
        'image_url': 'https://example.com/x.png',
      };
      final model = IntroductionsResponse.fromJson(minimal);
      expect(model.imageUrl, 'https://example.com/x.png');
      expect(model.title, isNull);
      expect(model.subtitle, isNull);
    });
  });
}
