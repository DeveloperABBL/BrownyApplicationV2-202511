import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/address_response.dart';
import 'package:browny_applications_new/feature/browny_shop/screens/ship_to_detail_page.dart';
import 'package:browny_applications_new/feature/browny_shop/viewmodel/customer_ship_to_viewmodel.dart';

/// หน้าเลือกที่อยู่จัดส่งของลูกค้า
///
/// Figma: node 56:17545
/// เปิดจากการ์ด "ที่อยู่จัดส่ง" ในหน้าสรุปคำสั่งซื้อ ([BrownyShopSelected])
/// แสดงที่อยู่ทั้งหมด (API), เลือก 1 รายการ แล้ว pop กลับพร้อม [AddressData]
/// รองรับลบ + ตั้งเป็นที่อยู่หลัก
///
/// TODO(figma): ปุ่มเพิ่ม/แก้ไขที่อยู่รอหน้าฟอร์ม (Figma) — ตอนนี้เป็น TODO
class CustomerShipToPage extends StatelessWidget {
  const CustomerShipToPage({super.key});

  static final pagePath = '/customer_ship_to';
  static final pageName = 'CustomerShipToPage';

  /// เปิดหน้านี้ — คืน [AddressData] ที่เลือก เมื่อกดปุ่ม "เลือกที่อยู่"
  static Future<AddressData?> goToPage(BuildContext context) async {
    return await context.pushNamed<AddressData>(CustomerShipToPage.pageName);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CustomerShipToViewModel(
        customerId: context.read<CustomerProvider>().current.id.orEmpty,
      )..load(),
      child: const _CustomerShipToWidget(),
    );
  }
}

class _CustomerShipToWidget extends StatelessWidget {
  const _CustomerShipToWidget();

  void _onAddAddress(BuildContext context, CustomerShipToViewModel vm) {
    ShipToDetailPage.goToPage(
      context,
      mode: ShipToDetailMode.add,
      viewModel: vm,
    );
  }

  void _onEdit(
    BuildContext context,
    CustomerShipToViewModel vm,
    AddressData address,
  ) {
    ShipToDetailPage.goToPage(
      context,
      mode: ShipToDetailMode.edit,
      viewModel: vm,
      address: address,
    );
  }

  /// ลบที่อยู่ — ยืนยันก่อน
  Future<void> _onDelete(
    BuildContext context,
    CustomerShipToViewModel vm,
    AddressData address,
  ) async {
    final id = address.id;
    if (id == null) return;
    final confirmed = await AppOverlays.showBrownyDialog(
      context,
      message: context.wording.deleteAddressConfirm,
      confirmText: context.wording.confirm,
      cancelText: context.wording.cancel,
    );
    if (confirmed != true || !context.mounted) return;
    final ok = await vm.deleteAddress(id);
    if (!ok && context.mounted) {
      AppOverlays.showToast(context, message: context.wording.errorUi);
    }
  }

  /// ตั้งที่อยู่นี้เป็นค่าเริ่มต้น
  Future<void> _onSetDefault(
    BuildContext context,
    CustomerShipToViewModel vm,
    AddressData address,
  ) async {
    final id = address.id;
    if (id == null) return;
    final ok = await vm.setDefault(id);
    if (!ok && context.mounted) {
      AppOverlays.showToast(context, message: context.wording.errorUi);
    }
  }

  void _onConfirm(BuildContext context, CustomerShipToViewModel vm) {
    final selected = vm.selectedAddress;
    if (selected == null) return;
    context.pop(selected);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<CustomerShipToViewModel>();
    return Scaffold(
      backgroundColor: AppColors.bareBackground,
      appBar: AppBar(
        flexibleSpace: FlexibleSpaceBar(
          background: Assets.png.bgAppBar.image(fit: BoxFit.cover),
        ),
        title: AppText(
          context.wording.address,
          style: context.appBarTextThemeWhite,
        ),
      ),
      body: _buildBody(context, vm),
      bottomNavigationBar: _buildBottomBar(context, vm),
    );
  }

  Widget _buildBody(BuildContext context, CustomerShipToViewModel vm) {
    return ValueListenableBuilder(
      valueListenable: vm.addressesNotifier,
      builder: (context, result, _) {
        if (result.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (result.isError) {
          return Center(
            child: GestureDetector(
              onTap: vm.load,
              behavior: HitTestBehavior.opaque,
              child: AppText(context.wording.errorUi),
            ),
          );
        }
        final addresses = result.data ?? const <AddressData>[];
        return Stack(
          children: [
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Container(
                color: AppColors.background,
                padding: EdgeInsets.all(AppDims.size_16.w),
                child: ValueListenableBuilder(
                  valueListenable: vm.selectedIdNotifier,
                  builder: (context, selectedId, _) => Column(
                    spacing: AppDims.size_16.h,
                    children: _buildItems(context, vm, addresses, selectedId),
                  ),
                ),
              ),
            ),
            // ระหว่างทำ action (ลบ/ตั้ง default) — บังจอ + loading
            Positioned.fill(
              child: ValueListenableBuilder(
                valueListenable: vm.busyNotifier,
                builder: (context, busy, _) {
                  if (!busy) return const SizedBox.shrink();
                  return ColoredBox(
                    color: AppColors.black.withValues(alpha: 0.04),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// การ์ดเพิ่มที่อยู่ + รายการที่อยู่ (คั่นด้วยเส้นแบ่ง)
  List<Widget> _buildItems(
    BuildContext context,
    CustomerShipToViewModel vm,
    List<AddressData> addresses,
    int? selectedId,
  ) {
    final items = <Widget>[
      _AddAddressCard(onTap: () => _onAddAddress(context, vm)),
    ];
    for (var i = 0; i < addresses.length; i++) {
      if (i > 0) {
        items.add(Container(height: 1, color: AppColors.border));
      }
      final address = addresses[i];
      items.add(
        _AddressCard(
          address: address,
          selected: address.id == selectedId,
          onTap: () => vm.select(address),
          onEdit: () => _onEdit(context, vm, address),
          onDelete: () => _onDelete(context, vm, address),
          onSetDefault: () => _onSetDefault(context, vm, address),
        ),
      );
    }
    return items;
  }

  /// แถบล่าง — ปุ่ม "เลือกที่อยู่" (กดได้เมื่อมีที่อยู่ที่เลือก)
  Widget _buildBottomBar(BuildContext context, CustomerShipToViewModel vm) {
    return ValueListenableBuilder(
      valueListenable: vm.selectedIdNotifier,
      builder: (context, _, _) {
        final enabled = vm.selectedAddress != null;
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x33928B8B),
                blurRadius: 16,
                spreadRadius: 8,
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(
            AppDims.size_24.w,
            AppDims.size_16.h,
            AppDims.size_24.w,
            AppDims.size_16.h,
          ),
          child: SafeArea(
            top: false,
            child: GestureDetector(
              onTap: enabled ? () => _onConfirm(context, vm) : null,
              child: Container(
                width: double.infinity,
                height: AppDims.size_40.h,
                decoration: BoxDecoration(
                  color: enabled ? AppColors.ci : AppColors.ctaPrimaryDisable,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: AppText(
                  context.wording.selectAddress,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// การ์ด "เพิ่มที่อยู่" — กรอบเทา มุมโค้ง + ไอคอน + ข้อความ
class _AddAddressCard extends StatelessWidget {
  const _AddAddressCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppDims.size_16.w,
          vertical: AppDims.size_32.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: AppColors.ci,
                borderRadius: BorderRadius.circular(2.r),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.add, size: 12.w, color: AppColors.white),
            ),
            SizedBox(width: AppDims.size_8.w),
            AppText(
              context.wording.addAddress,
              style: context.textTheme.titleSmall?.copyWith(
                fontSize: 14.sp,
                color: AppColors.ci,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// การ์ดที่อยู่ 1 รายการ — เลือกอยู่ = กรอบเขียว + ติ๊กถูก
class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  final AddressData address;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppDims.size_16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: selected ? Border.all(color: AppColors.ci) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Assets.icShop.icAddressHouse.image(width: 22.w, height: 22.w),
            SizedBox(width: AppDims.size_8.w),
            Expanded(child: _buildInfo(context)),
            SizedBox(width: AppDims.size_8.w),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: AppText(
                address.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.darkBrown,
                ),
              ),
            ),
            SizedBox(width: AppDims.size_4.w),
            AppText(
              address.phone ?? '',
              style: context.textTheme.titleSmall?.copyWith(
                fontSize: 14.sp,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDims.size_2.h),
        AppText(
          address.fullAddress,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            fontSize: 14.sp,
            color: AppColors.gray600,
          ),
        ),
        SizedBox(height: AppDims.size_8.h),
        // default = badge อ่านอย่างเดียว / ไม่ใช่ = ลิงก์ "ตั้งเป็นที่อยู่หลัก"
        if (address.isDefaultAddress)
          const _MainAddressBadge()
        else
          GestureDetector(
            onTap: onSetDefault,
            behavior: HitTestBehavior.opaque,
            child: AppText(
              context.wording.setAsMainAddress,
              style: context.textTheme.titleSmall?.copyWith(
                fontSize: 12.sp,
                color: AppColors.ci,
              ),
            ),
          ),
        SizedBox(height: AppDims.size_8.h),
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: onEdit,
            behavior: HitTestBehavior.opaque,
            child: AppText(
              context.wording.edit,
              style: context.textTheme.titleSmall?.copyWith(
                fontSize: 14.sp,
                color: AppColors.ci,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// คอลัมน์ขวา — ปุ่มลบ (บน) + ติ๊กถูก (ล่าง ถ้าเลือกอยู่)
  Widget _buildActions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onDelete,
          behavior: HitTestBehavior.opaque,
          child: Assets.icShop.icTrash.image(width: 18.w, height: 18.w),
        ),
        if (selected) ...[
          SizedBox(height: AppDims.size_48.h),
          Container(
            width: 18.w,
            height: 18.w,
            decoration: const BoxDecoration(
              color: AppColors.ci,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.check, size: 12.w, color: AppColors.white),
          ),
        ],
      ],
    );
  }
}

/// Badge "ที่อยู่หลัก" — pill gradient เหลือง→เขียว + ไอคอนบ้านในวงกลมขาว
class _MainAddressBadge extends StatelessWidget {
  const _MainAddressBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDims.size_8.w,
        vertical: AppDims.size_4.h,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.claimCoinButtonGradient,
        borderRadius: BorderRadius.circular(58.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Assets.icShop.icAddressHouse.image(),
          ),
          SizedBox(width: AppDims.size_4.w),
          AppText(
            context.wording.mainAddress,
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 12.sp,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
