import 'package:url_launcher/url_launcher.dart';

/// Helper class สำหรับจัดการการเปิด URL, โทรศัพท์, อีเมล และแอปอื่นๆ
class LaunchHelper {
  // Private constructor เพื่อป้องกันการสร้าง instance
  LaunchHelper._();

  /// เปิด URL ในเบราว์เซอร์
  ///
  /// [url] - URL ที่ต้องการเปิด (เช่น 'https://example.com')
  /// [mode] - โหมดการเปิด (inAppBrowserView, externalApplication, etc.)
  ///
  /// Returns [bool] true ถ้าเปิดสำเร็จ
  static Future<bool> openUrl(
    String url, {
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: mode);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// เปิด URL ในเบราว์เซอร์ภายนอก
  ///
  /// [url] - URL ที่ต้องการเปิด
  ///
  /// Returns [bool] true ถ้าเปิดสำเร็จ
  static Future<bool> openUrlInBrowser(String url) async {
    return await openUrl(url, mode: LaunchMode.externalApplication);
  }

  /// เปิด URL ใน WebView ภายในแอป
  ///
  /// [url] - URL ที่ต้องการเปิด
  ///
  /// Returns [bool] true ถ้าเปิดสำเร็จ
  static Future<bool> openUrlInWebView(String url) async {
    return await openUrl(url, mode: LaunchMode.inAppWebView);
  }

  /// โทรออก
  ///
  /// [phoneNumber] - เบอร์โทรศัพท์ที่ต้องการโทร (เช่น '0812345678' หรือ '+66812345678')
  ///
  /// Returns [bool] true ถ้าเปิดแอปโทรศัพท์สำเร็จ
  static Future<bool> makePhoneCall(String phoneNumber) async {
    // ลบช่องว่างและขีดออก
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s-]'), '');
    return await openUrl('tel:$cleanNumber');
  }

  /// ส่ง SMS
  ///
  /// [phoneNumber] - เบอร์โทรศัพท์ที่ต้องการส่ง SMS
  /// [message] - ข้อความที่ต้องการส่ง (optional)
  ///
  /// Returns [bool] true ถ้าเปิดแอป SMS สำเร็จ
  static Future<bool> sendSms(String phoneNumber, {String? message}) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s-]'), '');
    String smsUrl = 'sms:$cleanNumber';
    if (message != null && message.isNotEmpty) {
      smsUrl += '?body=${Uri.encodeComponent(message)}';
    }
    return await openUrl(smsUrl);
  }

  /// ส่งอีเมล
  ///
  /// [email] - อีเมลผู้รับ
  /// [subject] - หัวข้ออีเมล (optional)
  /// [body] - เนื้อหาอีเมล (optional)
  /// [cc] - อีเมล CC (optional)
  /// [bcc] - อีเมล BCC (optional)
  ///
  /// Returns [bool] true ถ้าเปิดแอปอีเมลสำเร็จ
  static Future<bool> sendEmail(
    String email, {
    String? subject,
    String? body,
    List<String>? cc,
    List<String>? bcc,
  }) async {
    String emailUrl = 'mailto:$email';
    List<String> params = [];

    if (subject != null && subject.isNotEmpty) {
      params.add('subject=${Uri.encodeComponent(subject)}');
    }
    if (body != null && body.isNotEmpty) {
      params.add('body=${Uri.encodeComponent(body)}');
    }
    if (cc != null && cc.isNotEmpty) {
      params.add('cc=${cc.join(',')}');
    }
    if (bcc != null && bcc.isNotEmpty) {
      params.add('bcc=${bcc.join(',')}');
    }

    if (params.isNotEmpty) {
      emailUrl += '?${params.join('&')}';
    }

    return await openUrl(emailUrl);
  }

  /// เปิด Google Maps ด้วยพิกัด
  ///
  /// [latitude] - ละติจูด
  /// [longitude] - ลองจิจูด
  /// [label] - ชื่อสถานที่ (optional)
  ///
  /// Returns [bool] true ถ้าเปิดแผนที่สำเร็จ
  static Future<bool> openMap(
    double latitude,
    double longitude, {
    String? label,
  }) async {
    String mapUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (label != null && label.isNotEmpty) {
      mapUrl += '&query_place_id=${Uri.encodeComponent(label)}';
    }
    return await openUrl(mapUrl);
  }

  /// เปิด Google Maps ด้วยที่อยู่
  ///
  /// [address] - ที่อยู่ที่ต้องการค้นหา
  ///
  /// Returns [bool] true ถ้าเปิดแผนที่สำเร็จ
  static Future<bool> openMapWithAddress(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    return await openUrl(
      'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
    );
  }

  /// เปิดแอป WhatsApp
  ///
  /// [phoneNumber] - เบอร์โทรศัพท์ในรูปแบบสากล (เช่น '+66812345678')
  /// [message] - ข้อความที่ต้องการส่ง (optional)
  ///
  /// Returns [bool] true ถ้าเปิด WhatsApp สำเร็จ
  static Future<bool> openWhatsApp(
    String phoneNumber, {
    String? message,
  }) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s+-]'), '');
    String whatsappUrl = 'https://wa.me/$cleanNumber';
    if (message != null && message.isNotEmpty) {
      whatsappUrl += '?text=${Uri.encodeComponent(message)}';
    }
    return await openUrl(whatsappUrl);
  }

  /// เปิดแอป LINE
  ///
  /// [lineId] - LINE ID ของผู้ใช้
  ///
  /// Returns [bool] true ถ้าเปิด LINE สำเร็จ
  static Future<bool> openLine(String lineId) async {
    return await openUrl('https://line.me/ti/p/$lineId');
  }

  /// เปิด Facebook Profile/Page
  ///
  /// [fbId] - Facebook ID หรือ username
  ///
  /// Returns [bool] true ถ้าเปิด Facebook สำเร็จ
  static Future<bool> openFacebook(String fbId) async {
    // ลองเปิด Facebook App ก่อน
    final appUrl = 'fb://profile/$fbId';
    final webUrl = 'https://www.facebook.com/$fbId';

    final uri = Uri.parse(appUrl);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    // ถ้าไม่สำเร็จให้เปิดในเบราว์เซอร์
    return await openUrl(webUrl);
  }

  /// เปิด Instagram Profile
  ///
  /// [username] - Instagram username
  ///
  /// Returns [bool] true ถ้าเปิด Instagram สำเร็จ
  static Future<bool> openInstagram(String username) async {
    return await openUrl('https://www.instagram.com/$username');
  }

  /// เปิด Twitter/X Profile
  ///
  /// [username] - Twitter username
  ///
  /// Returns [bool] true ถ้าเปิด Twitter สำเร็จ
  static Future<bool> openTwitter(String username) async {
    return await openUrl('https://twitter.com/$username');
  }

  /// เปิด YouTube Channel
  ///
  /// [channelId] - YouTube Channel ID หรือ username
  ///
  /// Returns [bool] true ถ้าเปิด YouTube สำเร็จ
  static Future<bool> openYouTube(String channelId) async {
    return await openUrl('https://www.youtube.com/channel/$channelId');
  }

  /// ตรวจสอบว่า URL สามารถเปิดได้หรือไม่
  ///
  /// [url] - URL ที่ต้องการตรวจสอบ
  ///
  /// Returns [bool] true ถ้าสามารถเปิดได้
  static Future<bool> canLaunch(String url) async {
    try {
      final uri = Uri.parse(url);
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  /// ปิด WebView ที่เปิดอยู่ (ใช้กับ LaunchMode.inAppWebView)
  static void closeWebView() {
    closeInAppWebView();
  }
}
