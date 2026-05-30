import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/browny_shop/models/browny_shop_order_status_model.dart';
import 'package:flutter/foundation.dart';

/// ViewModel หน้าสถานะคำสั่งซื้อ Browny Shop ([BrownyShopOrderStatusPage])
///
/// รับ [orderId] เพื่อใช้ fetch สถานะ/รายละเอียดทั้งหมด — API ยังไม่พร้อม จึง
/// mock ตาม design ไปก่อน (ดู [fetchOrderStatus])
class BrownyShopOrderStatusViewModel extends AppViewModel {
  BrownyShopOrderStatusViewModel({
    required super.context,
    required this.orderId,
  }) {
    fetchOrderStatus();
  }

  /// id คำสั่งซื้อ — ใช้ fetch สถานะทั้งหมดเมื่อ API พร้อม
  final String orderId;

  final _statusNotifier = ValueNotifier<UiResult<BrownyShopOrderStatusModel>>(
    UiResult.loading(),
  );
  ValueListenable<UiResult<BrownyShopOrderStatusModel>> get statusNotifier =>
      _statusNotifier;

  /// โหลดสถานะคำสั่งซื้อ
  ///
  /// TODO(api): ยังไม่มี API สถานะคำสั่งซื้อ Browny Shop — ตอนนี้คืน mock ตาม
  /// design; เมื่อ API พร้อมให้เรียก repo ด้วย [orderId] แล้ว map เป็น
  /// [BrownyShopOrderStatusModel]
  Future<void> fetchOrderStatus() async {
    _statusNotifier.value = UiResult.loading();
    _statusNotifier.value = UiResult.success(data: _mockData());
  }

  /// mock ข้อมูลตาม design (สถานะ "ชำระเงินแล้ว รอจัดส่ง")
  BrownyShopOrderStatusModel _mockData() {
    return BrownyShopOrderStatusModel(
      orderId: orderId,
      orderIdDisplay: 'BB33O3O4O82O221xx',
      status: BrownyShopOrderStatusType.paid,
      trackingNumber: null,
      recipientName: 'บราวนี่ รักสะอาด',
      phone: '080-000-0000',
      fullAddress:
          'ชั้น 2 Intree Organic Cafe 459 ถ.เพชรเกษม แขวงบางหว้า '
          'เขตภาษีเจริญ กรุงเทพมหานคร 10160 ประเทศไทย',
      products: const [
        BrownyShopOrderStatusProduct(
          name: 'Hygiene กลิ่นกุหลาบ Hygiene กลิ่นกุหลาบ',
          moneyPrice: 699,
          originalMoneyPrice: 1300,
          coinPrice: 699,
          originalCoinPrice: 800,
          quantity: 2,
          isFreeShipping: true,
        ),
        BrownyShopOrderStatusProduct(
          name: 'Hygiene กลิ่นกุหลาบ Hygiene กลิ่นกุหลาบ',
          moneyPrice: 699,
          originalMoneyPrice: 1300,
          coinPrice: 699,
          originalCoinPrice: 800,
          quantity: 2,
        ),
        BrownyShopOrderStatusProduct(
          name: 'Hygiene กลิ่นกุหลาบ Hygiene กลิ่นกุหลาบ',
          moneyPrice: 699,
          originalMoneyPrice: 1300,
          coinPrice: 699,
          originalCoinPrice: 800,
          quantity: 2,
          isFreeShipping: true,
        ),
      ],
      orderTotal: 75,
      paymentChannelName: 'TrueMoney Wallet',
      orderTime: '11-10-2-25 00:00',
      paymentTime: '11-10-2-25 00:00',
      deliveryTime: '11-10-2-25 00:00',
      qrImage: null,
    );
  }

  @override
  void dispose() {
    _statusNotifier.dispose();
    super.dispose();
  }
}
