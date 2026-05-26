import 'dart:convert';

import 'package:browny_applications_new/core/data/remote/models/request/cart_item_add_request.dart';
import 'package:browny_applications_new/core/data/remote/models/request/cart_item_quantity_request.dart';
import 'package:browny_applications_new/core/data/remote/models/response/cart_item_add_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/cart_item_remove_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/cart_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/flash_sales_response.dart';
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

/// Mixin Interface สำหรับ Repository ของ Browny Shop
mixin BrownyShopDataSourceMixin {
  /// API fetch รายการสินค้า Browny Shop
  ///
  /// Parameters:
  /// - productType: String (เช่น "all", "popular", "browny-sale")
  /// - customerId: String (uuid)
  Future<RepoResult<ProductsResponse>> fetchProducts({
    required String productType,
    required String customerId,
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
}

/// Repository สำหรับ Browny Shop feature
class BrownyShopRepo extends AppRepository with BrownyShopDataSourceMixin {
  @override
  Future<RepoResult<ProductsResponse>> fetchProducts({
    required String productType,
    required String customerId,
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
}
