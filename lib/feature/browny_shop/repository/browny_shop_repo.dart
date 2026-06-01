import 'dart:convert';

import 'package:browny_applications_new/core/data/remote/models/request/cart_item_add_request.dart';
import 'package:browny_applications_new/core/data/remote/models/request/cart_item_quantity_request.dart';
import 'package:browny_applications_new/core/data/remote/models/request/cart_summary_request.dart';
import 'package:browny_applications_new/core/data/remote/models/request/browny_shop_favorite_request.dart';
import 'package:browny_applications_new/core/data/remote/models/request/checkout_confirm_request.dart';
import 'package:browny_applications_new/core/data/remote/models/request/machine_order_review_request.dart';
import 'package:browny_applications_new/core/data/remote/models/response/cart_item_add_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/cart_item_remove_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/cart_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/browny_shop_order_detail_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/browny_shop_orders_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/checkout_draft_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/flash_sales_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/browny_shop_receipt_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/payment_status_check_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/product_detail_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/product_types_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
import 'package:browny_applications_new/core/data/repo/app_repository.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// ข้อผิดพลาด "สต็อกไม่พอ" — พก message จาก API (HTTP 422)
class CartStockException implements Exception {
  CartStockException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// ข้อผิดพลาดทั่วไปจาก Browny Shop API (HTTP 422) — พก message จาก server
/// เช่น "คูปองนี้ใช้ร่วมกับ Flash Sale ไม่ได้", "กรุณาเลือกที่อยู่จัดส่ง",
/// "จำนวน Browny Coin ไม่เพียงพอ"
class BrownyShopApiException implements Exception {
  BrownyShopApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Mixin Interface สำหรับ Repository ของ Browny Shop
mixin BrownyShopDataSourceMixin {
  /// API fetch รายการสินค้า Browny Shop
  ///
  /// Parameters:
  /// - productType: String (เช่น "all", "popular", "browny-sale")
  /// - customerId: String (uuid)
  /// - search: String? (ค้นหาชื่อสินค้า — optional)
  Future<RepoResult<ProductsResponse>> fetchProducts({
    required String productType,
    required String customerId,
    String? search,
  });

  /// API fetch รายการ Flash Sale ที่ active อยู่ (Browny Shop)
  Future<RepoResult<FlashSalesResponse>> fetchFlashSales();

  /// API fetch รายการประเภทสินค้า (สำหรับ chip filter) — Browny Shop
  Future<RepoResult<ProductTypesResponse>> fetchProductTypes();

  /// API fetch รายละเอียดสินค้า Browny Shop
  ///
  /// Parameters:
  /// - productId: String (uuid)
  /// - customerId: String (uuid)
  Future<RepoResult<ProductDetailResponse>> fetchProductDetail({
    required String productId,
    required String customerId,
  });

  /// API fetch ตะกร้าสินค้าของลูกค้า
  Future<RepoResult<CartData>> fetchCart({required String customerId});

  /// API เพิ่มสินค้าลงตะกร้า (ระบุ quantity ได้)
  Future<RepoResult<CartItemData>> addCartItem({
    required String customerId,
    required String productId,
    required int subId,
    required int quantity,
  });

  /// API ปรับจำนวนสินค้าในตะกร้า — ส่ง quantity สุดท้ายไปตั้งค่าโดยตรง
  /// (error เป็น [CartStockException] เมื่อสต็อกไม่พอ — HTTP 422)
  Future<RepoResult<CartItemData>> updateCartItemQuantity({
    required String customerId,
    required int itemId,
    required int quantity,
  });

  /// API ลบสินค้า 1 รายการออกจากตะกร้า
  Future<RepoResult<CartItemRemoveData>> removeCartItem({
    required String customerId,
    required int itemId,
  });

  /// API คำนวณ summary (ยอด/ส่วนลด/คูปอง/ค่าจัดส่ง) จาก items ที่เลือก
  /// — POST /browny-shop/cart/summary
  /// error เป็น [BrownyShopApiException] เมื่อคูปองใช้ไม่ได้ (HTTP 422)
  Future<RepoResult<CheckoutSummaryData>> fetchCartSummary({
    required String customerId,
    required List<CartSummaryItemRequest> items,
    int? couponCustomerId,
    String? paymentMethod,
    int? customerAddressId,
  });

  /// API ยืนยันสั่งซื้อ + เริ่ม process ชำระเงิน — POST /browny-shop/checkout/confirm
  /// error เป็น [BrownyShopApiException] เมื่อ 422 (ตะกร้าว่าง/ไม่มีที่อยู่/coin ไม่พอ/ฯลฯ)
  Future<RepoResult<CheckoutDraftData>> confirmCheckout({
    required String customerId,
    required int customerAddressId,
    required String paymentMethod,
    int? couponCustomerId,
    List<CartSummaryItemRequest>? items,
  });

  /// API polling สถานะการชำระเงิน — GET /payment/browny-shop/status/{paymentRef}
  Future<RepoResult<PaymentStatusCheckResponse>> checkPaymentStatus({
    required String paymentRef,
  });

  /// API ดึงใบเสร็จ Browny Shop — GET /browny-shop/orders/{orderId}/receipt
  Future<RepoResult<BrownyShopReceiptResponse>> fetchBrownyShopReceipt({
    required String orderId,
  });

  /// API toggle สินค้าโปรด
  /// - [favorite] = true  → POST /browny-shop/favorites (เพิ่ม)
  /// - [favorite] = false → DELETE /browny-shop/favorites/{productId} (ลบ)
  ///
  /// คืน favorite_status ล่าสุดจาก server
  Future<RepoResult<bool>> setFavorite({
    required String customerId,
    required String productId,
    required bool favorite,
  });

  /// API ส่งคะแนนรีวิวร้าน — POST /browny-shop/orders/{orderId}/review
  /// คืน true เมื่อ status == "success"
  Future<RepoResult<bool>> submitReview({
    required String orderId,
    required int score,
  });

  /// API ดึงรายละเอียด + สถานะคำสั่งซื้อ Browny Shop
  /// — GET /browny-shop/orders/{orderId}?customer_id=
  /// ใช้กับหน้า [BrownyShopOrderStatusPage]
  Future<RepoResult<BrownyShopOrderDetailData>> fetchOrderDetail({
    required String orderId,
    required String customerId,
  });

  /// API ดึง order ที่ยังรอชำระเงิน (pending_payment) พร้อม response_payload/
  /// payment_url — GET /browny-shop/checkout/{orderId}?customer_id=
  /// ใช้กลับเข้า process ชำระเงินจากหน้าสถานะคำสั่งซื้อ
  Future<RepoResult<CheckoutDraftData>> fetchPendingOrder({
    required String orderId,
    required String customerId,
  });

  /// API ดึงประวัติคำสั่งซื้อ Browny Shop — GET /browny-shop/orders
  /// กรองช่วงวันที่ได้ด้วย [startDate]/[endDate] (yyyy-MM-dd)
  Future<RepoResult<List<BrownyShopOrderItem>>> fetchBrownyShopOrders({
    required String customerId,
    String? startDate,
    String? endDate,
    int page,
    int perPage,
  });
}

/// Repository สำหรับ Browny Shop feature
class BrownyShopRepo extends AppRepository with BrownyShopDataSourceMixin {
  @override
  Future<RepoResult<ProductsResponse>> fetchProducts({
    required String productType,
    required String customerId,
    String? search,
  }) async {
    try {
      //       if (kDebugMode) {
      //         return RepoResult.success(
      //           data: ProductsResponse.fromJson(
      //             jsonDecode('''
      // {"product":[{"id":"019db317-e6a4-73ba-a831-f94116d397b0","is_free_shipping":false,"favorite_status":false,"has_flash_sale":false,"flash_sale_starts_at":null,"flash_sale_ends_at":null,"unit":{"th":"","en":"","zh":""},"translations":{"th":{"name":"เสื้อกันหนาว","description":"<p>จุดเด่นที่คุณไม่ควรพลาด!👕-เนื้อผ้านุ่มใส่สบายตลอดวันไม่ระคายเคืองผิว-ดีไซน์ทันสมัยเหมาะกับทุกเพศใส่คู่กับแฟนหรือเพื่อนก็ฟินสุดๆ-ฮู้ดด้านในป้องกันลมเย็นให้ความอบอุ่นในทุกฤดูกาลรายละเอียดสินค้าเสื้อสเวตเตอร์แจ็คเก็ตมีฮู้ดสำหรับทุกเพศผลิตจากเนื้อผ้านุ่มให้ความรู้สึกสบายเมื่อสวมใส่เหมาะสำหรับทั้งผู้ชายและผู้หญิงสามารถใส่คู่กับแฟนหรือเพื่อนได้อย่างลงตัวตัวเลือกสีและขนาดมีให้เลือกหลากหลายสีและขนาดตามความต้องการของคุณไม่ว่าจะเป็นสีดำสีเทาเข้มสีกรมท่าสีกากีสีเทาอ่อนสีขาวสีชมพูอ่อนหรือสีแดงไวน์พร้อมขนาดตั้งแต่Mถึง3XLตอบโจทย์ทุกสไตล์และรูปร่างข้อมูลเพิ่มเติมเหมาะสำหรับใส่ในทุกโอกาสไม่ว่าจะวันสบายๆหรือออกไปเที่ยวกับเพื่อนและครอบครัวเสื้อตัวนี้จะช่วยเสริมลุคให้ดูอบอุ่นและทันสมัยในทุกสถานการณ์</p>"},"en":{"name":"coat","description":"<p>KeyFeaturesYouCan'tMiss!👕-Softfabric,comfortabletowearallday,non-irritatingtotheskin.-Moderndesign,suitableforallgenders.Perfectformatchingoutfitswithyourpartnerorfriend.-Innerhoodprotectsagainstcoldwindandkeepsyouwarminallseasons.ProductDetails:Unisexhoodedsweatshirtjacketmadefromsoftfabricforcomfortablewear.Suitableforbothmenandwomen.Perfectformatchingoutfitswithyourpartnerorfriend.ColorandSizeOptions:Availableinavarietyofcolorsandsizestosuityourneeds,includingblack,darkgrey,navyblue,khaki,lightgrey,white,lightpink,orwinered,insizesMto3XLtosuiteverystyleandbodytype.AdditionalInformation:Suitableforalloccasions,whethercasualdaysorgoingoutwithfriendsandfamily.Thisjacketwilladdawarmandstylishlooktoanysituation.</p>"},"zh":{"name":"血清","description":"<p>不容錯過的亮點！👕-柔軟布料，全天穿著舒適，親膚不刺激。-時尚設計，男女皆宜。非常適合與伴侶或朋友搭配穿著。-內置兜帽，有效抵禦寒風，四季皆宜。產品詳情：這款男女皆宜的連帽衛衣外套採用柔軟布料，穿著舒適。男女皆可穿著。非常適合與伴侶或朋友搭配穿著。顏色和尺寸選擇：提供多種顏色和尺碼，滿足您的不同需求，包括黑色、深灰色、藏藍色、卡其色、淺灰色、白色、淺粉紅色和酒紅色，尺寸從M到3XL，適合各種風格和體型。其他資訊：適合各種場合，無論是休閒日常或與親朋好友外出。這款外套將為任何場合增添溫暖時尚的氣息。</p>"}},"product_subs":[{"id":17,"list_order":1,"name":{"th":"ไซส์m","en":"ืืmSize","zh":"M碼"},"original_coin_price":1190,"original_money_price":119,"coin_price":1190,"money_price":119,"is_flash_sale":false,"flash_sale":null,"image_url":"https://gateway.abgroup.co.th/storage/products/เสื้อกันหนาว"},{"id":18,"list_order":2,"name":{"th":"ไซส์xl","en":"xlSize","zh":"XL碼"},"original_coin_price":1220,"original_money_price":122,"coin_price":1220,"money_price":122,"is_flash_sale":false,"flash_sale":null,"image_url":"https://gateway.abgroup.co.th/storage/products/เสื้อกันหนาว"}],"main_image_url":"https://gateway.abgroup.co.th/storage/products/2zx2mMTjdFtfkAfito8k3xOjiipsgy86F8xOj9GB.png"},{"id":"019db31a-8688-7100-9a0d-58f0d0394224","is_free_shipping":false,"favorite_status":false,"has_flash_sale":false,"flash_sale_starts_at":null,"flash_sale_ends_at":null,"unit":{"th":"","en":"","zh":""},"translations":{"th":{"name":"เซรั่มบำรุงผม","description":"<p>จุดเด่นที่คุณต้องไม่พลาด!🌟</p><p>-ลดผมร่วงอย่างมีประสิทธิภาพเห็นผลจริง</p><p>-กระตุ้นผมใหม่ด้วยสารสกัดสมุนไพรธรรมชาติเช่นโสมแคนตาลูปและซอว์พาลเมตโต</p><p>-ใช้งานง่ายไม่เหนียวเหนอะหนะฉีดสเปรย์แล้วนวดเบาๆไม่ต้องล้างออก</p><p>&nbsp;</p><p>รายละเอียดสินค้า</p><p>โลชั่นบำรุงผมที่ออกแบบมาเพื่อแก้ปัญหาผมร่วงและผมบางโดยเฉพาะเสริมสร้างรากผมให้แข็งแรงพร้อมกระตุ้นการเกิดผมใหม่เหมาะสำหรับผู้ที่มีปัญหาผมบางหรือศีรษะล้านใช้งานสะดวกเพียงฉีดสเปรย์บนหนังศีรษะและนวดเบาๆวันละ2-3ครั้งไม่ต้องล้างออก</p><p>&nbsp;</p><p>ขอมูลเพิ่มเติม</p><p>เห็นผลชัดเจนเมื่อใช้ต่อเนื่องผมดูหนาขึ้นและสุขภาพดีขึ้นมีให้เลือกหลายขนาดตามความต้องการของคุณเหมาะสำหรับทุกเพศทุกวัยที่ต้องการดูแลสุขภาพผมให้แข็งแรงและดูดีขึ้นทุกวัน!</p>"},"en":{"name":"Hairserum","description":"<p>KeyFeaturesYouCan'tMiss!🌟</p><p>-Effectivelyreduceshairlosswithvisibleresults.</p><p>-Stimulatesnewhairgrowthwithnaturalherbalextractssuchasginseng,cantaloupe,andsawpalmetto.</p><p>-Easytouse,non-sticky.Simplysprayandgentlymassage;norinsingrequired.</p><p>ProductDetails</p><p>Ahairlotionspecificallydesignedtoaddresshairlossandthinning.Strengthenshairrootsandstimulatesnewhairgrowth.Idealforthosewiththinninghairorbaldness.Easytouse:simplysprayontothescalpandgentlymassage2-3timesdaily.Norinsingrequired.</p><p>AdditionalInformation</p>"},"zh":{"name":"血清","description":"<p>不容錯過的關鍵特性！🌟</p><p>-有效減少掉髮，效果顯著。</p><p>-蘊含人蔘、哈密瓜、鋸棕櫚等天然草本萃取物，促進新發生長。</p><p>-使用方便，清爽不黏膩。只需噴灑並輕輕按摩，無需沖洗。</p><p>產品詳情</p><p>這款護髮乳液專為解決脫髮和頭髮稀疏問題而設計。強健髮根，促進新發生長。尤其適合頭髮稀疏或禿頭人士。使用方法簡單：只需噴灑於頭皮，每日2-3次輕輕按摩即可。無需沖洗。</p><p>附加資訊</p><p>明顯效果，笑得合不攏嘴…</p>"}},"product_subs":[{"id":15,"list_order":1,"name":{"th":"1ขวด","en":"1bottle","zh":"1瓶"},"original_coin_price":1450,"original_money_price":145,"coin_price":1450,"money_price":145,"is_flash_sale":false,"flash_sale":null,"image_url":"https://gateway.abgroup.co.th/storage/products/serum"},{"id":16,"list_order":2,"name":{"th":"2ขวด","en":"2bottle","zh":"2瓶"},"original_coin_price":2750,"original_money_price":275,"coin_price":2750,"money_price":275,"is_flash_sale":false,"flash_sale":null,"image_url":"https://gateway.abgroup.co.th/storage/products/serum"}],"main_image_url":"https://gateway.abgroup.co.th/storage/products/4NAsXIdO7h8YTX1ZyDTBJ7MgiZLBfs1HLBol7vDc.png"},{"id":"019db320-264d-7215-bae8-5540f6a63918","is_free_shipping":false,"favorite_status":false,"has_flash_sale":false,"flash_sale_starts_at":null,"flash_sale_ends_at":null,"unit":{"th":"","en":"","zh":""},"translations":{"th":{"name":"เสื้อกันหนาวลายน้องบราวนี่","description":"<p>เสื้อกันหนาวยีนส์ยี่ห้อBrownystandardfreesize</p><p>อก40นิ้วเสื้อมือสองราคาถูกพร้อมส่ง</p><p>&nbsp;</p><p>📍วัดจากสินค้าจริง</p><p>อก40นิ้ว</p><p>ความยาวเสื้อ56เซนติเมตร</p><p>ความยาวแขนเสื้อ58เซนติเมตร</p><p>เป็นเสื้อกันหนาวยีนส์ด้านในเป็นผ้าร่ม</p><p>ดีทรายคอปกด้วยขนสังเคราะห์กันหนาวได้</p><p>ด้านหน้ามีกระเป๋าสองด้าน</p><p>ใส่กันหนาวเป็นเสื้อคลุมน่ารักมากๆเลยค่ะ</p><p>สภาพ85%ไม่มีตำหนิใช้งานได้ปกติ</p><p>&nbsp;</p><p>📍✨แนะนำให้เทียบขนาดของสินค้าในรายละเอียดที่วัดให้เทียบกับผู้ใส่จะช่วยเรื่องการเลือกขนาดได้แม่นยำกว่าค่ะ&nbsp;</p><p>&nbsp;</p><p>🔅สินค้าเป็นสินค้ามือสอง(สภาพดี)</p><p>(ซักทำความสะอาดแล้วพร้อมใช้งาน)</p><p>&nbsp;</p><p>📍สินค้ามีเพียง1ชิ้น✅&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p><p>📍ใช้งานได้ปกติไม่ชำรุด</p><p>&nbsp;</p><p>🔅ส่งของทุกวัน✅</p><p>&nbsp;</p><p>สนใจทักแชทถามรายละเอียดสินค้าได้ค่ะ</p><p>&nbsp;</p><p>แม่ค้าใจดีทักแชทต่อราคาได้ค่ะ🙏🏻😊</p>"},"en":{"name":"coatBrowny","description":"<p>Brownybrandstandardfreesizedenimjacket.</p><p>Chest40inches.Secondhandjacket,affordableprice,readytoship.</p><p>📍Measurementstakenfromtheactualitem:</p><p>Chest:40inches</p><p>Jacketlength:56centimeters</p><p>Sleevelength:58centimeters</p><p>Denimjacketwithawindbreakerlining.</p><p>Featuresafauxfurcollarforaddedwarmth.</p><p>Twofrontpockets.</p><p>Verycuteandwarmasajacket.</p><p>Condition:85%,nodefects,fullyfunctional.</p><p>📍✨Werecommendcomparingthemeasurementsprovidedinthedescriptiontoyourownmeasurementsformoreaccuratesizing.</p><p>🔅Secondhanditem(goodcondition).</p><p>(Washedandcleaned,readytouse).</p><p>📍Only1itemavailable✅</p><p>📍Fullyfunctional,nodamage.</p><p>🔅Shippingdaily✅</p><p>Interested?Messageusfordetails.</p><p>Friendlyseller,feelfreetonegotiatetheprice!🙏😊</p>"},"zh":{"name":"外套","description":"<p>Browny品牌標準均碼牛仔外套。</p><p>胸圍40吋。二手外套，價格實惠，現貨發售。</p><p>📍以下尺寸為實物測量：</p><p>胸圍：40英寸</p><p>衣長：56厘米</p><p>袖長：58厘米</p><p>牛仔外套，附防風內襯。</p><p>附有人造毛領，更加保暖。</p><p>兩個前口袋。</p><p>非常可愛又保暖。</p><p>成色：85%，無瑕疵，功能齊全。</p><p>📍✨為了更準確地選擇尺寸，我們建議您將描述中的尺寸與您的實際尺寸進行比較。</p><p>🔅二手商品（成色好）。</p><p>（已清洗乾淨，可直接穿著）。</p><p>📍只剩一件✅</p><p>📍功能齊全，無損壞。</p><p>🔅每日出貨✅</p><p>有興趣？請私訊我們了解詳情。</p><p>友善賣家，價格可議！🙏😊</p>"}},"product_subs":[{"id":19,"list_order":1,"name":{"th":"ไซส์XXL","en":"XXLSize","zh":"XXL碼"},"original_coin_price":1990,"original_money_price":199,"coin_price":1990,"money_price":199,"is_flash_sale":false,"flash_sale":null,"image_url":"https://gateway.abgroup.co.th/storage/products/เสื้อกันหนาว"}],"main_image_url":"https://gateway.abgroup.co.th/storage/products/dt8a66qsodSzYCsQ1lxHjIQrpOauVFZ3vWw9J050.png"},{"id":"019db324-2b75-72fc-82a7-edd615d79a1a","is_free_shipping":false,"favorite_status":false,"has_flash_sale":false,"flash_sale_starts_at":null,"flash_sale_ends_at":null,"unit":{"th":"","en":"","zh":""},"translations":{"th":{"name":"เซรั่มบำรุงผิวหน้า","description":"<p>จุดเด่นที่คุณต้องลอง!✨</p><p>-ลดรอยสิวและจุดด่างดำได้อย่างเห็นผล</p><p>-ผิวกระจ่างใสดูสุขภาพดี</p><p>-สูตรอ่อนโยนปราศจากแอลกอฮอล์และพาราเบน</p><p>&nbsp;</p><p>รายละเอียดสูตรที่ตอบโจทย์ทุกปัญหาผิว</p><p>-ทีทรีแอคเน่:ดูแลผิวมันและปัญหาสิว</p><p>-วิตซีออเรนจ์:ผิวขาวกระจ่างใสเติมความชุ่มชื้น</p><p>-โปรเมกาเนตสร้างผิว:ฟื้นบำรุงผิวให้แข็งแรงลดเลือนรอยสิว</p><p>-เกรฟซีด:ดูแลฝ้ากระและจุดด่างดำ</p><p>&nbsp;</p><p>ข้อมูลเพิ่มเติมที่ควรรู้</p><p>-เซรั่มเข้มข้นขนาด30มล.เหมาะกับทุกสภาพผิว</p><p>-ปราศจากแอลกอฮอล์พาราเบนน้ำหอมและซิลิโคน</p><p>-ใช้ได้ทุกวันเช้า-เย็นเพื่อผลลัพธ์ที่ดีที่สุด</p><p>&nbsp;</p><p>เหมาะสำหรับผู้ที่ต้องการดูแลผิวให้กระจ่างใสลดรอยสิวและจุดด่างดำพร้อมสูตรอ่อนโยนที่ใส่ใจทุกความต้องการของผิวคุณ!</p>"},"en":{"name":"Facialserum","description":"<p>Must-tryhighlights!✨</p><p>-Effectivelyreducesacnescarsanddarkspots.</p><p>-Brightensskinandpromotesahealthyglow.</p><p>-Gentleformula,alcohol-freeandparaben-free.</p><p>Formuladetailsaddressingvariousskinconcerns:</p><p>-TeaTreeAcne:Caresforoilyandacne-proneskin.</p><p>-VitaminCOrange:Brightensskinandprovideshydration.</p><p>-PomegranateSkinRegeneration:Strengthensskinandreducesacnescars.</p><p>-GrapeSeed:Treatsmelasma,freckles,anddarkspots.</p><p>AdditionalInformation:</p><p>-Concentratedserum,30ml.Suitableforallskintypes.</p><p>-Freefromalcohol,parabens,fragrance,andsilicone.</p><p>-Usedaily,morningandevening,forbestresults.</p><p>Idealforthoseseekingbrighterskin,reducedacnescarsanddarkspots,withagentleformulathatcaterstoallyourskin'sneeds!</p>"},"zh":{"name":"臉部精華液","description":"<p>必試亮點！✨</p><p>-有效淡化痘印和色斑。</p><p>-提亮膚色，煥發健康光澤。</p><p>-溫和配方，不含酒精和防腐劑。</p><p>針對不同肌膚問題的配方詳情：</p><p>-茶樹祛痘：呵護油性及易長痘肌膚。</p><p>-維生素C柳橙：提亮膚色，補水保濕。</p><p>-石榴煥膚：強韌肌膚，淡化痘印。</p><p>-葡萄籽：淡化黃褐斑、雀斑和色斑。</p><p>其他資訊：</p><p>-濃縮精華液，30毫升。適合所有膚質。</p><p>-不含酒精、防腐劑、香精和矽酮。</p><p>-每日早晚使用，效果更佳。</p><p>這款溫和配方滿足您肌膚的各種需求，是追求亮白肌膚、淡化痘印和色斑人士的理想選擇！</p>"}},"product_subs":[{"id":13,"list_order":1,"name":{"th":"ขนาด30มล.","en":"30ml.","zh":"30毫升"},"original_coin_price":1630,"original_money_price":163,"coin_price":1630,"money_price":163,"is_flash_sale":false,"flash_sale":null,"image_url":"https://gateway.abgroup.co.th/storage/products/เซรั่มบำรุงผิวหน้า"},{"id":14,"list_order":2,"name":{"th":"60มล.","en":"60ml.","zh":"60毫升"},"original_coin_price":2800,"original_money_price":280,"coin_price":2800,"money_price":280,"is_flash_sale":false,"flash_sale":null,"image_url":"https://gateway.abgroup.co.th/storage/products/เซรั่มบำรุงผิวหน้า"}],"main_image_url":"https://gateway.abgroup.co.th/storage/products/MP2PPj39CqRX1VFrXCbKEHNBpnBfYHES3PwiNlTp.png"},{"id":"019db330-0dff-723c-928e-2d26cb981f0d","is_free_shipping":false,"favorite_status":false,"has_flash_sale":false,"flash_sale_starts_at":null,"flash_sale_ends_at":null,"unit":{"th":"","en":"","zh":""},"translations":{"th":{"name":"หมอนลายน้องบราวนี่","description":"<p>รายละเอียดสินค้า</p><p>–ผลิตจากเส้นใยTotoriCloudFiberที่มีความละเอียดและนุ่มกว่าขนห่านแท้ถึง3เท่า</p><p>–ให้สัมผัสนุ่มฟูรองรับสรีระศีรษะและต้นคอได้อย่างดี</p><p>–สามารถปรับความสูงของหมอนได้ตามความต้องการเฉพาะบุคคลเพื่อความสบายสูงสุดขณะนอนหลับ</p><p>–ช่วยลดความเมื่อยล้าและทำให้นอนหลับได้ง่ายขึ้น</p><p>–เหมาะสำหรับทุกสไตล์การนอนทั้งนอนหงายตะแคงหรือคว่ำ</p><p>&nbsp;</p><p>ขนาด</p><p>–ปริมาณไส้หมอนตามรุ่น(หน่วยเป็นกรัม)</p><p>&nbsp;</p><p>สีหรือรุ่น</p><p>–รุ่นCloud(TotoriCloudModel)</p><p>&nbsp;</p><p>ตัวเลือกสินค้า</p><p>–1200g(หมอนต่ำ)</p><p>–1700g(หมอนกลาง)</p><p>&nbsp;</p>"},"en":{"name":"ฺBrownypillow","description":"<p>ProductDetails</p><p>–MadefromTotoriCloudFiber,whichis3timesfinerandsofterthanrealgoosedown.</p><p>–Providesasoftandfluffyfeel,supportingtheheadandneckwell.</p><p>–Thepillowheightcanbeadjustedtosuitindividualneedsformaximumcomfortwhilesleeping.</p><p>–Helpsreducefatigueandpromoteseasiersleep.</p><p>–Suitableforallsleepingstyles:back,side,orstomach.</p><p>Size</p><p>–Pillowfillingquantitybymodel(ingrams)</p><p>ColororModel</p><p>–CloudModel(TotoriCloudModel)</p><p>ProductOptions</p><p>–1200g(LowPillow)</p><p>–1700g(MediumPillow)</p><p>&nbsp;</p>"},"zh":{"name":"枕頭","description":"<p>產品詳情</p><p>–採用Totori雲朵纖維製成，比真正的鵝絨細膩柔軟三倍。</p><p>–觸感柔軟蓬鬆，為頭部和頸部提供良好支撐。</p><p>–枕頭高度可調節，滿足不同睡眠需求，帶來極致舒適體驗。</p><p>–有助於緩解疲勞，促進睡眠。</p><p>–適合所有睡姿：仰臥、側臥或俯臥。</p><p>尺寸</p><p>–各型號枕芯填充量（公克）</p><p>顏色或型號</p><p>–雲朵款（Totori雲朵款）</p><p>產品選項</p><p>–1200公克（低枕頭）</p><p>–1700公克（中枕）</p><p>&nbsp;</p>"}},"product_subs":[{"id":11,"list_order":1,"name":{"th":"หมอนต่ำ","en":"LowPillow","zh":"低枕頭"},"original_coin_price":1580,"original_money_price":158,"coin_price":1580,"money_price":158,"is_flash_sale":false,"flash_sale":null,"image_url":"https://gateway.abgroup.co.th/storage/products/LowPillow"},{"id":12,"list_order":2,"name":{"th":"หมอนกลาง","en":"MediumPillow","zh":"中枕"},"original_coin_price":1650,"original_money_price":165,"coin_price":1650,"money_price":165,"is_flash_sale":false,"flash_sale":null,"image_url":"https://gateway.abgroup.co.th/storage/products/MediumPillow"}],"main_image_url":"https://gateway.abgroup.co.th/storage/products/imlrdZ0WwiIOPSAnwJMrgKg98AjGvYEqwLMBMshI.png"},{"id":"019db334-f289-73d3-980c-fde0c52c78e0","is_free_shipping":false,"favorite_status":false,"has_flash_sale":false,"flash_sale_starts_at":null,"flash_sale_ends_at":null,"unit":{"th":"","en":"","zh":""},"translations":{"th":{"name":"หมอนหนุน","description":"<p>สัมผัสความนุ่มสบายหมอนหนุนใยสังเคราะห์ซาตินขนาด19”x29”มอบความนุ่มสบายที่คุณต้องการในทุกค่ำคืนด้วยสีขาวที่สะอาดตาและเข้ากับทุกสไตล์การตกแต่งห้องนอนของคุณคุณสมบัติพิเศษหมอนนี้ผลิตจากใยสังเคราะห์เกรดAที่ให้ความนุ่มสบายและรองรับการใช้งานในชีวิตประจำวันได้อย่างดีเยี่ยมขนาดมาตรฐาน19”x29”ทำให้เหมาะสำหรับการใช้งานทั่วไปวัสดุคุณภาพผ้าคอตตอน35%ผ้าโพลีเอสเตอร์65%ทอละเอียด290เส้นด้าย/10ตร.ซม.ช่วยให้หมอนมีความทนทานและนุ่มสบายให้หมอนหนุนใยสังเคราะห์ซาตินเป็นส่วนหนึ่งของการพักผ่อนที่สมบูรณ์แบบของคุณ!</p>"},"en":{"name":"pillow","description":"<p>Experienceultimatecomfortwiththis19”x29”satinfiberpillow.Enjoythesoftcomfortyoudesireeverynight.Itscleanwhitecolorcomplementsanybedroomdecor.Specialfeatures:MadefromGradeAfibersforexceptionalsoftnessandsupport.Standardsize19”x29”foreverydayuse.Qualitymaterials:35%cotton,65%polyester,wovenwith290threads/10sqcmfordurabilityandcomfort.Letthissatinfiberpillowbeapartofyourperfectrelaxation!</p>"},"zh":{"name":"緞面枕頭","description":"<p>這款19吋x29吋的緞紋纖維枕，帶給您極致舒適體驗。每晚都能享受您夢寐以求的柔軟舒適。潔白的顏色，與任何臥室裝潢風格都能完美搭配。產品特色：採用A級纖維製成，帶來卓越的柔軟度和支撐力。標準尺寸19英寸x29英寸，適合日常使用。優質布料：35%棉，65%滌綸，每10平方公分290根紗線織造，經久耐用，舒適無比。讓這款緞紋纖維枕頭成為您完美放鬆體驗的一部分！</p>"}},"product_subs":[{"id":10,"list_order":1,"name":{"th":"หมอนหนุน","en":"pillow","zh":"緞面枕頭"},"original_coin_price":1580,"original_money_price":158,"coin_price":1580,"money_price":158,"is_flash_sale":false,"flash_sale":null,"image_url":"https://gateway.abgroup.co.th/storage/products/pillow"}],"main_image_url":"https://gateway.abgroup.co.th/storage/products/Gtib16jRyawJ2hLuiwZ59HmsHLHcKxAgLlo3SWD4.png"}]}
      // '''),
      //           ),
      //         );
      //       }
      final response = await requireRemote.fetchProducts(
        productType,
        customerId,
        search: search,
      );
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<FlashSalesResponse>> fetchFlashSales() async {
    try {
      // if (kDebugMode) {
      //   // return RepoResult.empty();
      //   return RepoResult.success(
      //     data: FlashSalesResponse.fromJson(
      //       jsonDecode('''
      // {"flash_sales":[{"id":1,"name":"ถัง","start_at":"2026-05-05 16:45:00","end_at":"2026-05-22 16:45:00","status":"active","products":[{"id":"019e166c-fab0-7150-9c02-c637bc8751c5","is_free_shipping":false,"is_flash_sale":true,"flash_sale":{"id":1,"name":"ถัง","start_at":"2026-05-05 16:45:00","end_at":"2026-05-22 16:45:00","special_money_price":1500,"special_coin_price":null,"scope":"product","coin_value":10,"coin_price_source":"calculated"},"unit":{"th":"ชิ้น","en":"ชิ้น","zh":"ชิ้น"},"translations":{"th":{"name":"ของเล่น","description":"<p>้่เ้าเ</p>"},"en":{"name":"ของเล่น","description":"<p>กหเดกหเ</p>"},"zh":{"name":"ของเล่น","description":"<p>ดเกห</p>"}},"main_image_url":"http://127.0.0.1:8000/storage/products/kSTUbzVD44SjU9RhtZya0VNFGIYtCtlB4JFDXVoK.png","product_subs":[{"id":4,"list_order":1,"name":{"th":"สีขาว","en":"สีขาว","zh":"สีขาว"},"original_coin_price":20000,"original_money_price":2000,"coin_price":15000,"money_price":1500,"coin_discount_percent":25,"money_discount_percent":25,"is_flash_sale":true,"flash_sale":{"id":1,"name":"ถัง","start_at":"2026-05-05 16:45:00","end_at":"2026-05-22 16:45:00","special_money_price":1500,"special_coin_price":null,"scope":"product","coin_value":10,"coin_price_source":"calculated"},"image_url":"http://127.0.0.1:8000/storage/products/jey2d49W0aA8KhAYhcOWBTZqwC23QsFs22os0NVX.png"},{"id":5,"list_order":2,"name":{"th":"สีดำ","en":"สีดำ","zh":"สีดำ"},"original_coin_price":5000.25,"original_money_price":500.38,"coin_price":4500.36,"money_price":450.25,"coin_discount_percent":10,"money_discount_percent":10.02,"is_flash_sale":true,"flash_sale":{"id":1,"name":"ถัง","start_at":"2026-05-05 16:45:00","end_at":"2026-05-22 16:45:00","special_money_price":450.25,"special_coin_price":4500.36,"scope":"variant","coin_value":10,"coin_price_source":"manual"},"image_url":"http://127.0.0.1:8000/storage/products/GNCQjywizIknZo4LCymO8hW468JyyXwD8t3Q4kgC.png"}]}]}]}
      // '''),
      //     ),
      //   );
      // }
      final response = await requireRemote.fetchFlashSales();
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<ProductTypesResponse>> fetchProductTypes() async {
    try {
      final response = await requireRemote.fetchProductTypes();
      if (!response.isSuccessful) return RepoResult.empty();
      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<ProductDetailResponse>> fetchProductDetail({
    required String productId,
    required String customerId,
  }) async {
    try {
      //       if (kDebugMode) {
      //         return RepoResult.success(
      //           data: ProductDetailResponse.fromJson(
      //             jsonDecode('''
      // {"product":{"id":"019db324-2b75-72fc-82a7-edd615d79a1a","is_free_shipping":false,"favorite_status":false,"has_flash_sale":false,"flash_sale_starts_at":null,"flash_sale_ends_at":null,"unit":{"th":"","en":"","zh":""},"translations":{"th":{"name":"เซรั่มบำรุงผิวหน้า","description":"<p>จุดเด่นที่คุณต้องลอง!✨</p><p>-ลดรอยสิวและจุดด่างดำได้อย่างเห็นผล</p><p>-ผิวกระจ่างใสดูสุขภาพดี</p><p>-สูตรอ่อนโยนปราศจากแอลกอฮอล์และพาราเบน</p><p>&nbsp;</p><p>รายละเอียดสูตรที่ตอบโจทย์ทุกปัญหาผิว</p><p>-ทีทรีแอคเน่:ดูแลผิวมันและปัญหาสิว</p><p>-วิตซีออเรนจ์:ผิวขาวกระจ่างใสเติมความชุ่มชื้น</p><p>-โปรเมกาเนตสร้างผิว:ฟื้นบำรุงผิวให้แข็งแรงลดเลือนรอยสิว</p><p>-เกรฟซีด:ดูแลฝ้ากระและจุดด่างดำ</p><p>&nbsp;</p><p>ข้อมูลเพิ่มเติมที่ควรรู้</p><p>-เซรั่มเข้มข้นขนาด30มล.เหมาะกับทุกสภาพผิว</p><p>-ปราศจากแอลกอฮอล์พาราเบนน้ำหอมและซิลิโคน</p><p>-ใช้ได้ทุกวันเช้า-เย็นเพื่อผลลัพธ์ที่ดีที่สุด</p><p>&nbsp;</p><p>เหมาะสำหรับผู้ที่ต้องการดูแลผิวให้กระจ่างใสลดรอยสิวและจุดด่างดำพร้อมสูตรอ่อนโยนที่ใส่ใจทุกความต้องการของผิวคุณ!</p>"},"en":{"name":"Facialserum","description":"<p>Must-tryhighlights!✨</p><p>-Effectivelyreducesacnescarsanddarkspots.</p><p>-Brightensskinandpromotesahealthyglow.</p><p>-Gentleformula,alcohol-freeandparaben-free.</p><p>Formuladetailsaddressingvariousskinconcerns:</p><p>-TeaTreeAcne:Caresforoilyandacne-proneskin.</p><p>-VitaminCOrange:Brightensskinandprovideshydration.</p><p>-PomegranateSkinRegeneration:Strengthensskinandreducesacnescars.</p><p>-GrapeSeed:Treatsmelasma,freckles,anddarkspots.</p><p>AdditionalInformation:</p><p>-Concentratedserum,30ml.Suitableforallskintypes.</p><p>-Freefromalcohol,parabens,fragrance,andsilicone.</p><p>-Usedaily,morningandevening,forbestresults.</p><p>Idealforthoseseekingbrighterskin,reducedacnescarsanddarkspots,withagentleformulathatcaterstoallyourskin'sneeds!</p>"},"zh":{"name":"臉部精華液","description":"<p>必試亮點！✨</p><p>-有效淡化痘印和色斑。</p><p>-提亮膚色，煥發健康光澤。</p><p>-溫和配方，不含酒精和防腐劑。</p><p>針對不同肌膚問題的配方詳情：</p><p>-茶樹祛痘：呵護油性及易長痘肌膚。</p><p>-維生素C柳橙：提亮膚色，補水保濕。</p><p>-石榴煥膚：強韌肌膚，淡化痘印。</p><p>-葡萄籽：淡化黃褐斑、雀斑和色斑。</p><p>其他資訊：</p><p>-濃縮精華液，30毫升。適合所有膚質。</p><p>-不含酒精、防腐劑、香精和矽酮。</p><p>-每日早晚使用，效果更佳。</p><p>這款溫和配方滿足您肌膚的各種需求，是追求亮白肌膚、淡化痘印和色斑人士的理想選擇！</p>"}},"product_subs":[{"id":13,"list_order":1,"name":{"th":"ขนาด30มล.","en":"30ml.","zh":"30毫升"},"original_coin_price":1630,"original_money_price":163,"coin_price":1630,"money_price":163,"is_flash_sale":false,"flash_sale":null,"image_url":"https://gateway.abgroup.co.th/storage/products/เซรั่มบำรุงผิวหน้า","stock":"30.00"},{"id":14,"list_order":2,"name":{"th":"60มล.","en":"60ml.","zh":"60毫升"},"original_coin_price":2800,"original_money_price":280,"coin_price":2800,"money_price":280,"is_flash_sale":false,"flash_sale":null,"image_url":"https://gateway.abgroup.co.th/storage/products/เซรั่มบำรุงผิวหน้า","stock":"20.00"}],"main_image_url":"https://gateway.abgroup.co.th/storage/products/MP2PPj39CqRX1VFrXCbKEHNBpnBfYHES3PwiNlTp.png"}}
      // '''),
      //           ),
      //         );
      //       }
      final response = await requireRemote.fetchProductDetail(
        productId,
        customerId,
      );
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<CartData>> fetchCart({
    required String customerId,
  }) async {
    try {
      final response = await requireRemote.fetchCart(customerId);
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      final data = response.data.data;
      if (data == null) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<CartItemData>> addCartItem({
    required String customerId,
    required String productId,
    required int subId,
    required int quantity,
  }) async {
    try {
      final response = await requireRemote.addCartItem(
        customerId,
        CartItemAddRequest(
          productId: productId,
          productSubId: subId,
          quantity: quantity,
        ),
      );
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      final data = response.data.data;
      if (data == null) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<CartItemData>> updateCartItemQuantity({
    required String customerId,
    required int itemId,
    required int quantity,
  }) async {
    try {
      final response = await requireRemote.updateCartItemQuantity(
        customerId,
        itemId,
        CartItemQuantityRequest(quantity: quantity),
      );
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      final data = response.data.data;
      if (data == null) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: data);
    } on DioException catch (e) {
      // HTTP 422 = สต็อกไม่พอ — ดึง message จาก response body มาแจ้ง user
      final body = e.response?.data;
      final message = body is Map ? body['message']?.toString() : null;
      if (message != null && message.isNotEmpty) {
        return RepoResult.error(error: CartStockException(message));
      }
      return RepoResult.error(error: e);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<CartItemRemoveData>> removeCartItem({
    required String customerId,
    required int itemId,
  }) async {
    try {
      final response = await requireRemote.removeCartItem(
        customerId,
        itemId,
      );
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      final data = response.data.data;
      if (data == null) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  /// ดึง message จาก error body (HTTP 422) — ใช้ทั้ง cart summary / confirm
  String? _messageOf(DioException e) {
    final body = e.response?.data;
    final message = body is Map ? body['message']?.toString() : null;
    return (message != null && message.isNotEmpty) ? message : null;
  }

  @override
  Future<RepoResult<CheckoutSummaryData>> fetchCartSummary({
    required String customerId,
    required List<CartSummaryItemRequest> items,
    int? couponCustomerId,
    String? paymentMethod,
    int? customerAddressId,
  }) async {
    try {
      // TODO(api): backend ยังไม่ส่งข้อมูลจริง — mock ตาม changelog ก่อน
      // if (kDebugMode) {
      //   final json = couponCustomerId != null
      //       ? _mockSummaryWithCoupon
      //       : _mockSummaryNoCoupon;
      //   return RepoResult.success(
      //     data: CheckoutSummaryData.fromJson(
      //       jsonDecode(json)['data'] as Map<String, dynamic>,
      //     ),
      //   );
      // }
      final response = await requireRemote.calculateBrownyShopCartSummary(
        CartSummaryRequest(
          customerId: customerId,
          items: items,
          couponCustomerId: couponCustomerId,
          paymentMethod: paymentMethod,
          customerAddressId: customerAddressId,
        ),
      );
      if (!response.isSuccessful) return RepoResult.empty();
      final data = response.data.data;
      if (data == null) return RepoResult.empty();
      return RepoResult.success(data: data);
    } on DioException catch (e) {
      // 422 = คูปองใช้ไม่ได้ — พก message มาแจ้ง user
      final message = _messageOf(e);
      if (e.response?.statusCode == 422 && message != null) {
        return RepoResult.error(error: BrownyShopApiException(message));
      }
      return RepoResult.error(error: e);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<CheckoutDraftData>> confirmCheckout({
    required String customerId,
    required int customerAddressId,
    required String paymentMethod,
    int? couponCustomerId,
    List<CartSummaryItemRequest>? items,
  }) async {
    try {
      // TODO(api): backend ยังไม่ส่งข้อมูลจริง — mock ตาม changelog ก่อน
      if (kDebugMode) {
        final json = paymentMethod == 'coin'
            ? _mockConfirmCoin
            : paymentMethod == 'tp_wallet'
            ? _mockConfirmWallet
            : _mockConfirmQr;
        return RepoResult.success(
          data: CheckoutDraftData.fromJson(
            jsonDecode(json)['data'] as Map<String, dynamic>,
          ),
        );
      }
      final response = await requireRemote.confirmBrownyShopCheckout(
        CheckoutConfirmRequest(
          customerId: customerId,
          customerAddressId: customerAddressId,
          paymentMethod: paymentMethod,
          couponCustomerId: couponCustomerId,
          items: items,
        ),
      );
      if (!response.isSuccessful) return RepoResult.empty();
      final data = response.data.data;
      if (data == null) return RepoResult.empty();
      return RepoResult.success(data: data);
    } on DioException catch (e) {
      // 422 = ตะกร้าว่าง / ไม่มีที่อยู่ / coin ไม่พอ / สร้าง QR ไม่ได้ ฯลฯ
      final message = _messageOf(e);
      if (e.response?.statusCode == 422 && message != null) {
        return RepoResult.error(error: BrownyShopApiException(message));
      }
      return RepoResult.error(error: e);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<PaymentStatusCheckResponse>> checkPaymentStatus({
    required String paymentRef,
  }) async {
    try {
      // TODO(api): mock = paid เพื่อให้ flow เดินจนถึงหน้า receipt ตอน debug
      if (kDebugMode) {
        return RepoResult.success(
          data: PaymentStatusCheckResponse.fromJson(
            jsonDecode(_mockPaymentPaid) as Map<String, dynamic>,
          ),
        );
      }
      final response = await requireRemote.checkBrownyShopPaymentStatus(
        paymentRef,
      );
      if (!response.isSuccessful) return RepoResult.empty();
      return RepoResult.success(data: response.data);
    } on DioException catch (e) {
      // 412 = ยังไม่ชำระ (pending) — ไม่ใช่ error จริง, parse body เป็น pending
      final body = e.response?.data;
      if (e.response?.statusCode == 412 && body is Map<String, dynamic>) {
        return RepoResult.success(
          data: PaymentStatusCheckResponse.fromJson(body),
        );
      }
      return RepoResult.error(error: e);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<BrownyShopReceiptResponse>> fetchBrownyShopReceipt({
    required String orderId,
  }) async {
    try {
      if (kDebugMode) {
        return RepoResult.success(
          data: BrownyShopReceiptResponse.fromJson(
            jsonDecode(_mockReceipt) as Map<String, dynamic>,
          ),
        );
      }
      final response = await requireRemote.fetchBrownyShopReceipt(orderId);
      if (!response.isSuccessful) return RepoResult.empty();
      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<bool>> setFavorite({
    required String customerId,
    required String productId,
    required bool favorite,
  }) async {
    try {
      if (favorite) {
        final response = await requireRemote.addBrownyShopFavorite(
          BrownyShopFavoriteRequest(
            customerId: customerId,
            productId: productId,
          ),
        );
        if (!response.isSuccessful) return RepoResult.empty();
        return RepoResult.success(
          data: response.data.data?.favoriteStatus ?? true,
        );
      }
      final response = await requireRemote.removeBrownyShopFavorite(
        productId,
        customerId,
      );
      if (!response.isSuccessful) return RepoResult.empty();
      return RepoResult.success(
        data: response.data.data?.favoriteStatus ?? false,
      );
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<bool>> submitReview({
    required String orderId,
    required int score,
  }) async {
    try {
      // TODO(api): backend ยังไม่พร้อม — mock = success ตอน debug
      if (kDebugMode) {
        return RepoResult.success(data: true);
      }
      final response = await requireRemote.submitBrownyShopReview(
        orderId,
        MachineOrderReviewRequest(score: score),
      );
      if (!response.isSuccessful) return RepoResult.empty();
      return RepoResult.success(data: response.data.isSuccess);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<BrownyShopOrderDetailData>> fetchOrderDetail({
    required String orderId,
    required String customerId,
  }) async {
    try {
      // TODO(api): backend ยังไม่พร้อม — mock ตาม changelog ตอน debug
      // if (kDebugMode) {
      //   return RepoResult.success(
      //     data: BrownyShopOrderDetailData.fromJson(
      //       jsonDecode(_mockOrderDetail)['data'] as Map<String, dynamic>,
      //     ),
      //   );
      // }
      final response = await requireRemote.fetchBrownyShopOrderDetail(
        orderId,
        customerId,
      );
      if (!response.isSuccessful) return RepoResult.empty();
      final data = response.data.data;
      if (data == null) return RepoResult.empty();
      return RepoResult.success(data: data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<CheckoutDraftData>> fetchPendingOrder({
    required String orderId,
    required String customerId,
  }) async {
    try {
      // TODO(api): backend ยังไม่พร้อม — mock = order รอชำระ (QR) ตอน debug
      if (kDebugMode) {
        return RepoResult.success(
          data: CheckoutDraftData.fromJson(
            jsonDecode(_mockConfirmQr)['data'] as Map<String, dynamic>,
          ),
        );
      }
      final response = await requireRemote.fetchBrownyShopOrder(
        orderId,
        customerId,
      );
      if (!response.isSuccessful) return RepoResult.empty();
      final data = response.data.data;
      if (data == null) return RepoResult.empty();
      return RepoResult.success(data: data);
    } on DioException catch (e) {
      // 404 = ไม่ใช่ pending / ไม่ใช่ของลูกค้า
      final message = _messageOf(e);
      if (message != null) {
        return RepoResult.error(error: BrownyShopApiException(message));
      }
      return RepoResult.error(error: e);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<List<BrownyShopOrderItem>>> fetchBrownyShopOrders({
    required String customerId,
    String? startDate,
    String? endDate,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      // TODO(api): backend ยังไม่พร้อม — mock ตาม changelog ตอน debug
      // if (kDebugMode) {
      //   final res = BrownyShopOrdersResponse.fromJson(
      //     jsonDecode(_mockOrders) as Map<String, dynamic>,
      //   );
      //   return RepoResult.success(data: res.data ?? const []);
      // }
      final response = await requireRemote.fetchBrownyShopOrders(
        customerId,
        page,
        perPage,
        startDate: startDate,
        endDate: endDate,
      );
      if (!response.isSuccessful) return RepoResult.empty();
      final data = response.data.data;
      if (data == null) return RepoResult.empty();
      return RepoResult.success(data: data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  // ===== Mock responses (kDebugMode) — ตาม browny-shop-api-changelog-2026-05-30 =====

  static const _mockSummaryWithCoupon = '''
{"success":true,"data":{"subtotal":300.0,"shipping_total":25.0,"flash_sale_discount":50.0,"product_discount":0.0,"coupon_discount":30.0,"total_discount":80.0,"price_original":325.0,"final_price":295.0,"coin_amount_required":null,"coin_value":10.0,"coupon_customer_id":123,"payment_method":"qr","coupon":{"coupon_id":10,"customer_coupon_id":123,"discount_target":"product","discount_type":"percent","value":"10.00","max_discount":"100.00","min_order_amount":"500.00","allow_with_promotion":false,"allow_with_product_discount":true,"remaining":"1","expires_at":"2026-12-31 23:59:59","used_quantity":"0","name":{"th":"ลด 10%","en":"10% off","zh":"九折"},"description":{"th":"ใช้ได้กับ Browny Shop","en":"Valid for Browny Shop","zh":""},"image_url":{"th":"","en":"","zh":""}},"items":[]}}
''';

  static const _mockSummaryNoCoupon = '''
{"success":true,"data":{"subtotal":300.0,"shipping_total":25.0,"flash_sale_discount":0.0,"product_discount":0.0,"coupon_discount":0.0,"total_discount":0.0,"price_original":325.0,"final_price":325.0,"coin_amount_required":null,"coin_value":10.0,"coupon_customer_id":null,"payment_method":null,"items":[]}}
''';

  static const _mockConfirmQr = '''
{"success":true,"data":{"id":"c3d4e5f6-a7b8-9012-cdef-345678901234","customer_id":"a1b2c3d4-e5f6-7890-abcd-ef1234567890","status":"pending_payment","payment_method":"qr","payment_status":"pending","payment_ref":"202605301234567","subtotal":300.0,"shipping_total":25.0,"flash_sale_discount":0.0,"product_discount":0.0,"coupon_discount":30.0,"discount_amount":30.0,"price_original":325.0,"price_final":295.0,"coin_amount_used":null,"coin_value":10.0,"expires_at":"2026-05-30 18:00:00","paid_at":null,"receipt_no":null,"customer_address_id":1,"payment_url":"https://example.com/pay/browny-shop/202605301234567","response_payload":{"qrcode":"00020101021229370016A000000677010112011300668999999999530376454032755802TH6304ABCD"}}}
''';

  static const _mockConfirmCoin = '''
{"success":true,"data":{"id":"c3d4e5f6-a7b8-9012-cdef-345678901234","customer_id":"a1b2c3d4-e5f6-7890-abcd-ef1234567890","status":"paid","payment_method":"coin","payment_status":"paid","payment_ref":"202605301234568","subtotal":300.0,"shipping_total":25.0,"coupon_discount":0.0,"discount_amount":0.0,"price_original":325.0,"price_final":325.0,"coin_amount_used":3250.0,"coin_value":10.0,"paid_at":"2026-05-30 13:05:22","receipt_no":"BNS20260530-130522123456","customer_address_id":1,"payment_url":null,"response_payload":{"method":"coin","amount":325.0,"coin_amount_used":3250.0}}}
''';

  static const _mockConfirmWallet = '''
{"success":true,"data":{"id":"c3d4e5f6-a7b8-9012-cdef-345678901234","status":"paid","payment_method":"tp_wallet","payment_status":"paid","price_final":295.0,"payment_ref":"202605301234570","receipt_no":"BNS20260530-130522777777","paid_at":"2026-05-30 13:05:22","customer_address_id":1,"payment_url":null,"response_payload":{"method":"wallet","amount":295.0,"coin_amount_used":null}}}
''';

  static const _mockPaymentPaid = '''
{"status":"success","payment_status":"paid","order_id":"c3d4e5f6-a7b8-9012-cdef-345678901234","receipt_no":"BNS20260530-130522123456","redirect":"https://example.com/api/browny-shop/orders/c3d4e5f6-a7b8-9012-cdef-345678901234/receipt"}
''';

  static const _mockReceipt = '''
{"order_id":"c3d4e5f6-a7b8-9012-cdef-345678901234","payment_ref":"202605301234568","receipt_no":"BNS20260530-130522123456","type":"browny_shop","total":"295.00","price_original":"325.00","price_final":"295.00","discount_amount":"75.00","total_quantity":6,"payment_icon":"","payment_channel":"tp_wallet","payment_display":{"th":"TrueMoney Wallet","en":"TrueMoney Wallet","zh":"TrueMoney Wallet"},"paid_at":"2026-05-30 13:05:22","receipt_at":"2026-05-30 13:05:22","coin_amount_used":null,"coin_value":null,"lucky_no":"23","lucky_image":"","shipping_address":{"id":1,"recipient_name":"บราวนี่ รักสะอาด","first_name":"บราวนี่","last_name":"รักสะอาด","phone":"080-000-0000","zipcode":"10160","province":"กรุงเทพมหานคร","district":"ภาษีเจริญ","subdistrict":"บางหว้า","address":"459 ถ.เพชรเกษม","full_address":"ชั้น 2 Intree Organic Cafe 459 ถ.เพชรเกษม แขวง บางหว้า เขตภาษีเจริญ กรุงเทพมหานคร 10160 ประเทศไทย","country":"Thailand"},"summary":{"quantity":{"wording":{"th":"จำนวน","en":"Quantity","zh":""},"amount":"6"},"subtotal":{"wording":{"th":"ยอดรวมสินค้า","en":"Subtotal","zh":""},"amount":"76.00"},"discount":{"wording":{"th":"ส่วนลด","en":"Discount","zh":""},"amount":"-75.00"},"flash_sale_discount":{"wording":{"th":"ส่วนลด Flash Sale","en":"Flash Sale","zh":""},"amount":"-50.00"},"product_discount":{"wording":{"th":"ส่วนลดสินค้า","en":"Product Discount","zh":""},"amount":"0.00"},"coupon_discount":{"wording":{"th":"คูปองและรหัสคูปอง","en":"Coupon","zh":""},"amount":"-20.00","code":"PROMO2026","coupon_name":{"th":"ลด 20 บาท","en":"20 Baht Off","zh":""}},"shipping":{"wording":{"th":"การจัดส่ง","en":"Shipping","zh":""},"amount":"0.00"},"total":{"wording":{"th":"ยอดชำระทั้งหมด","en":"Total","zh":""},"amount":"295.00"}},"items":[],"call_center":"099-635-1211","line_link":"https://line.me/ti/p/@browny", "lucky_image": "https://gateway2026.abgroup.co.th/images/lucky_no/85.png","qr_image": "https://gateway2026.abgroup.co.th/storage/qrcodes/5159.png"}
''';

  static const _mockOrderDetail = '''
{  "success": true,  "data": {    "type": "browny_shop_order",    "order_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",    "payment_ref": "202610101234567",    "receipt_no": "BS-20260601-0003",    "status": "delivered",    "status_label": {      "th": "จัดส่งแล้ว",      "en": "Delivered",      "zh": "已发货"    },    "status_steps": {      "ordered": { "done": true, "at": "2026-10-10 10:00:00" },      "paid": { "done": true, "at": "2026-10-10 10:05:00" },      "shipping": { "done": true, "at": "2026-10-14 15:30:00" }    },    "tracking_number": "394320849388",    "shipping_provider": {      "id": 1,      "code": "flash",      "name": "Flash Express",      "logo_url": "https://example.com/storage/shipping-providers/flash.png",      "track_url": null    },    "price_original": "1300.00",    "price_final": "699.00",    "amount": "699.00",    "discount_amount": "601.00",    "total_quantity": 2,    "item_count": 2,    "payment_method": "qr",    "payment_icon": "qr",    "payment_channel": "qr",    "payment_display": { "th": "QR Code", "en": "QR Code", "zh": "二维码" },    "created_at": "2026-10-10 10:00:00",    "paid_at": "2026-10-10 10:05:00",    "shipped_at": "2026-10-12 14:00:00",    "delivered_at": "2026-10-14 15:30:00",    "delivery_date": "2026-10-14",    "receipt_at": "2026-10-10 10:05:00",    "review_score": null,    "bonus": "6990.00",    "qr_image": "https://example.com/storage/qrcodes/a1b2c3d4-e5f6-7890-abcd-ef1234567890.png",    "shipping_address": {      "recipient_name": "บราวนี่ รักสะอาด",      "first_name": "บราวนี่",      "last_name": "รักสะอาด",      "phone": "0800000000",      "zipcode": "10160",      "province": "กรุงเทพมหานคร",      "district": "ภาษีเจริญ",      "subdistrict": "บางหว้า",      "address": "ชั้น 2 Intree Organic Cafe 459 ถ.เพชรเกษม",      "full_address": "ชั้น 2 Intree Organic Cafe 459 ถ.เพชรเกษม แขวงบางหว้า เขตภาษีเจริญ กรุงเทพมหานคร 10160",      "country": "ประเทศไทย",      "note": null    },    "summary": {      "quantity": { "wording": { "th": "จำนวน", "en": "Quantity", "zh": "数量" }, "amount": "2" },      "subtotal": { "wording": { "th": "ยอดรวมสินค้า", "en": "Subtotal", "zh": "商品合计" }, "amount": "1300.00" },      "discount": { "wording": { "th": "ส่วนลด", "en": "Discount", "zh": "折扣" }, "amount": "-601.00" },      "shipping": { "wording": { "th": "การจัดส่ง", "en": "Shipping", "zh": "配送" }, "amount": "0.00" },      "total": { "wording": { "th": "ยอดชำระทั้งหมด", "en": "Total payment", "zh": "应付总额" }, "amount": "699.00" }    },    "items": [      {        "product_id": "f9e8d7c6-b5a4-3210-fedc-ba0987654321",        "product_sub_id": 16,        "quantity": 2,        "name": { "th": "Hygiene กลิ่นกุหลาบ...", "en": "Hygiene Rose...", "zh": "" },        "unit": { "th": "ขวด", "en": "bottle", "zh": "" },        "image_url": "https://example.com/storage/products/hygiene.png",        "unit_money_price": 699.00,        "original_money_price": 1300.00,        "line_subtotal": 1300.00,        "flash_sale_discount": 601.00,        "product_discount": 0.00,        "unit_shipping_fee": 0.00,        "bonus": "6990.00",        "is_flash_sale": true,        "unit_coin_price": 6990,        "original_coin_price": 13000,        "flash_sale_id": 3,        "line_shipping_fee": 0      }    ],    "call_center": "099-635-1211",    "line_link": "https://line.me/R/ti/p/%40browny"  }}
''';

  static const _mockOrders = '''
{"success":true,"data":[{"type":"browny_shop_order","order_id":"9234545","receipt_no":null,"status":"pending_payment","status_label":{"th":"รอชำระเงิน","en":"Awaiting payment","zh":"待付款"},"delivered_at":null,"delivery_date":null,"amount":"299.00","price_final":"299.00","item_count":1,"line_count":1,"title":{"th":"หมวก Browny","en":"Browny Cap","zh":"Browny Cap"},"preview_image":"https://gateway.abgroup.co.th/storage/products/bag.jpg","items":[{"name":{"th":"หมวก Browny","en":"Browny Cap","zh":"Browny Cap"},"image_url":"https://gateway.abgroup.co.th/storage/products/bag.jpg","quantity":1}],"sort_at":"2026-05-31 09:00:00"},{"type":"browny_shop_order","order_id":"019db31a-8688-7100-9a0d-58f0d0394224","receipt_no":"BS-20260531-0001","status":"delivered","status_label":{"th":"จัดส่งแล้ว","en":"Delivered","zh":"已发货"},"delivered_at":"2026-05-31 15:30:00","delivery_date":"2026-05-31","amount":"599.00","price_final":"599.00","item_count":3,"line_count":2,"title":{"th":"เสื้อยืด Browny (+1)","en":"Browny T-Shirt (+1)","zh":"Browny T-Shirt (+1)"},"preview_image":"https://gateway.abgroup.co.th/storage/products/tshirt-red.jpg","items":[],"sort_at":"2026-05-31 15:30:00"}],"meta":{"current_page":1,"per_page":20,"total":2,"last_page":1}}
''';
}
