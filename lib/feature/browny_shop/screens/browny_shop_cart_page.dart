import 'dart:async';

import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/feature/authentication/screen/authentication_page.dart';
import 'package:browny_applications_new/feature/authentication/viewmodel/authentication_viewmodel.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:browny_applications_new/feature/browny_shop/screens/browny_shop_selected_page.dart';
import 'package:browny_applications_new/feature/browny_shop/viewmodel/browny_shop_selected_viewmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

/// หน้าตะกร้าสินค้า Browny Shop
///
/// Figma: node 56:20258
/// ดึงตะกร้าจาก API ผ่าน [BrownyShopSelectedViewModel] (server เป็น source of truth)
/// การแก้จำนวนใช้ debounced batch sync — ดูคอมเมนต์ใน ViewModel
///
/// flow "ซื้อเลย": เข้าจากหน้ารายละเอียดสินค้าพร้อม [buyNowSubId]/[buyNowQuantity]
/// → โหลดตะกร้า, เลือกเฉพาะสินค้านั้น, ตั้งจำนวนตามที่เลือก แล้วเด้งเข้าหน้าสรุปทันที
class BrownyShopCartPage extends StatelessWidget {
  const BrownyShopCartPage({
    super.key,
    this.buyNowSubId,
    this.buyNowQuantity,
  });

  /// productSubId ของสินค้าที่กด "ซื้อเลย" — null = เข้าตะกร้าปกติ
  final int? buyNowSubId;

  /// จำนวนที่เลือกใน bottom sheet (ใช้คู่กับ [buyNowSubId])
  final int? buyNowQuantity;

  static final pagePath = '/browny_shop_cart';
  static final pageName = 'BrownyShopCart';

  static Future<T?> goToPage<T>(
    BuildContext context, {
    int? buyNowSubId,
    int? buyNowQuantity,
  }) async {
    // (subId, quantity) สำหรับ flow ซื้อเลย — null = เข้าตะกร้าปกติ
    final Object? extra = buyNowSubId == null
        ? null
        : (buyNowSubId, buyNowQuantity ?? 1);
    if (context.read<CustomerProvider>().current.isGuest) {
      await AuthenticationPage.goToPage(
        context,
        process: AuthenProcess.login,
      );
      if (!context.mounted) return null;
      if (!context.read<CustomerProvider>().current.isGuest) {
        return await context.pushNamed(
          BrownyShopCartPage.pageName,
          extra: extra,
        );
      }
    }
    return await context.pushNamed(
      BrownyShopCartPage.pageName,
      extra: extra,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BrownyShopSelectedViewModel(
        context: context,
        repo: BrownyShopRepo(),
      ),
      child: _BrownyShopCartWidget(
        buyNowSubId: buyNowSubId,
        buyNowQuantity: buyNowQuantity,
      ),
    );
  }
}

class _BrownyShopCartWidget extends StatefulWidget {
  const _BrownyShopCartWidget({this.buyNowSubId, this.buyNowQuantity});

  /// productSubId ของสินค้าที่กด "ซื้อเลย" — null = เข้าตะกร้าปกติ
  final int? buyNowSubId;

  /// จำนวนที่เลือกใน bottom sheet (ใช้คู่กับ [buyNowSubId])
  final int? buyNowQuantity;

  @override
  State<_BrownyShopCartWidget> createState() => _BrownyShopCartWidgetState();
}

class _BrownyShopCartWidgetState extends State<_BrownyShopCartWidget> {
  BrownyShopSelectedViewModel? _vmRef;

  /// guard ให้ auto-route ของ flow "ซื้อเลย" ทำครั้งเดียว
  bool _didAutoRoute = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<BrownyShopSelectedViewModel>();
      _vmRef = vm;
      vm.attachContext(context);
      vm.addListener(_onVmChanged);
      await vm.loadCart();
      if (!mounted) return;
      _maybeAutoRouteBuyNow(vm);
    });
  }

  /// flow "ซื้อเลย" — เลือกเฉพาะสินค้าที่กดมา, ตั้งจำนวนตามที่เลือก
  /// แล้วเด้งเข้าหน้าสรุป ([BrownyShopSelected]) ทันที (ทำครั้งเดียว)
  void _maybeAutoRouteBuyNow(BrownyShopSelectedViewModel vm) {
    final subId = widget.buyNowSubId;
    if (subId == null || _didAutoRoute) return;
    if (vm.hasError || vm.isEmpty) return;

    final matches = vm.lines.where((l) => l.data.productSubId == subId);
    if (matches.isEmpty) return;
    final line = matches.first;
    _didAutoRoute = true;

    // เลือกเฉพาะสินค้าที่กดซื้อเลย
    vm.setAllSelected(false);
    vm.toggleSelected(line);

    // ตั้งจำนวนตามที่เลือก — ถ้าต่างจาก server, debounced sync จะแก้ให้
    final qty = widget.buyNowQuantity;
    if (qty != null && qty >= 1 && line.quantity != qty) {
      vm.setQuantity(line, qty);
    }

    BrownyShopSelected.goToPage(context, viewModel: vm);
  }

  @override
  void dispose() {
    _vmRef?.removeListener(_onVmChanged);
    super.dispose();
  }

  /// surface sync error เป็น toast (อ่านครั้งเดียวแล้วเคลียร์)
  /// — มีข้อความเฉพาะ (เช่น สต็อกไม่พอ HTTP 422) แสดงข้อความนั้นแทน wording กลาง
  void _onVmChanged() {
    final vm = _vmRef;
    if (vm != null && vm.syncError) {
      final message = vm.syncErrorMessage;
      vm.consumeSyncError();
      if (mounted) {
        AppOverlays.showToast(
          context,
          message: message ?? context.wording.errorUi,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          AppDims.size_56.h + MediaQuery.of(context).padding.top,
        ),
        child: _buildAppBar(context),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Consumer<BrownyShopSelectedViewModel>(
          builder: (context, vm, _) => _buildBody(context, vm),
        ),
      ),
      bottomNavigationBar: Consumer<BrownyShopSelectedViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading || vm.hasError || vm.isEmpty) {
            return const SizedBox.shrink();
          }
          return _CheckoutBar(vm: vm);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, BrownyShopSelectedViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.hasError) {
      return Center(child: AppText(context.wording.errorUi));
    }
    if (vm.isEmpty) {
      return _buildEmpty(context);
    }
    return Stack(
      children: [
        ListView.separated(
          itemCount: vm.lines.length,
          separatorBuilder: (_, _) => Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
            child: const Divider(),
          ),
          itemBuilder: (context, index) {
            final line = vm.lines[index];
            return _CartItemCard(
              key: ValueKey(line.selectionKey),
              line: line,
              syncing: vm.isSyncing,
              onToggleSelected: () => vm.toggleSelected(line),
              onQuantityChanged: (q) => vm.setQuantity(line, q),
              onRequestRemove: () => _confirmRemove(context, vm, line),
            );
          },
        ),
        // ระหว่าง batch sync — บัง list กันแก้ไขซ้อน + แสดง loading
        if (vm.isSyncing)
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.black.withValues(alpha: 0.04),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  /// ยืนยันก่อนลบรายการออกจากตะกร้า (เรียกเมื่อจำนวนจะเหลือ 0)
  Future<void> _confirmRemove(
    BuildContext context,
    BrownyShopSelectedViewModel vm,
    CartLine line,
  ) async {
    await AppOverlays.showBrownyDialog(
      context,
      message: context.wording.removeCartItemConfirm,
      confirmText: context.wording.confirm,
      cancelText: context.wording.cancel,
      onConfirm: () {
        vm.removeLine(line);
      },
    );
  }

  /// AppBar — bg gradient image + back (white) + title "ตะกร้า"
  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image: Assets.png.bgAppBar.provider(),
        ),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTopRow(context),
            AppDims.vericalPadding_8,
          ],
        ),
      ),
    );
  }

  /// Top Row: back (white) + title "ตะกร้า" กลาง
  Widget _buildTopRow(BuildContext context) {
    return SizedBox(
      height: AppDims.size_39.h,
      child: Stack(
        alignment: AlignmentGeometry.center,
        children: [
          Row(
            spacing: AppDims.size_4.w,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppText(
                context.wording.cart,
                style: context.textTheme.titleMedium?.copyWith(
                  fontSize: 20.sp,
                  color: AppColors.white,
                ),
              ),
              Assets.icShop.icBagOutline2.image(width: AppDims.size_20.w),
            ],
          ),
          Align(
            alignment: AlignmentGeometry.centerLeft,
            child: BackButton(color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          alignment: AlignmentGeometry.topCenter,
          image: Assets.png.bgPawnPattern.provider(),
          repeat: ImageRepeat.repeatY,
          isAntiAlias: true,
          opacity: 0.15,
        ),
      ),
      child: Center(
        child: Column(
          spacing: AppDims.size_16.h,
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.icShop.bronwyShopOrderEmpty.image(width: 200.w),
            AppDims.vericalPadding_16,
            SizedBox(
              width: 200.w,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                child: AppText(context.wording.goShoppingNow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// การ์ดสินค้า 1 รายการในตะกร้า
class _CartItemCard extends StatefulWidget {
  const _CartItemCard({
    super.key,
    required this.line,
    required this.syncing,
    required this.onToggleSelected,
    required this.onQuantityChanged,
    required this.onRequestRemove,
  });

  final CartLine line;

  /// กำลัง batch sync — disable การแก้ไขจำนวน
  final bool syncing;
  final VoidCallback onToggleSelected;

  /// แจ้งจำนวนใหม่ (>= 1) ให้ ViewModel
  final ValueChanged<int> onQuantityChanged;

  /// ขอลบรายการ (จำนวนจะเหลือ 0) — page จะถามยืนยันก่อน
  final VoidCallback onRequestRemove;

  @override
  State<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<_CartItemCard> {
  late final TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: '${widget.line.quantity}');
  }

  @override
  void didUpdateWidget(covariant _CartItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // sync controller เมื่อจำนวนฝั่ง server เปลี่ยน (เช่น หลัง batch sync)
    if (widget.line.quantity != oldWidget.line.quantity &&
        _qtyController.text != '${widget.line.quantity}') {
      _qtyController.text = '${widget.line.quantity}';
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  CartLine get _line => widget.line;

  /// stock สูงสุด (อาศัย product ที่ nest มา — null = ไม่จำกัด)
  int? get _stockMax {
    final raw = _line.data.matchedSub?.stock;
    if (raw == null || raw.isEmpty) return null;
    return num.tryParse(raw)?.toInt();
  }

  /// ใช้จำนวนใหม่ (clamp 1..stock) แล้วแจ้ง ViewModel
  void _applyQuantity(int next) {
    final clamped = next.clamp(1, _stockMax ?? 99999);
    if (_qtyController.text != '$clamped') {
      _qtyController.text = '$clamped';
      _qtyController.selection = TextSelection.fromPosition(
        TextPosition(offset: _qtyController.text.length),
      );
    }
    if (clamped == _line.quantity) return;
    widget.onQuantityChanged(clamped);
  }

  void _onIncrement() => _applyQuantity(_line.quantity + 1);

  void _onDecrement() {
    if (_line.quantity > 1) {
      _applyQuantity(_line.quantity - 1);
    } else {
      // จำนวน = 1 อยู่แล้ว → ขอลบ (page จะถามยืนยัน)
      widget.onRequestRemove();
    }
  }

  /// commit ค่าจาก keyboard
  void _onQuantityInput(String text) {
    final parsed = int.tryParse(text);
    if (parsed == null) {
      // ค่าว่าง/ผิด — ปล่อยให้ user พิมพ์ต่อ ยังไม่ revert
      return;
    }
    if (parsed <= 0) {
      // พิมพ์ 0 → ขอลบ; revert ช่องกลับเป็นค่าเดิมไว้ก่อน (กันค้าง 0)
      _qtyController.text = '${_line.quantity}';
      widget.onRequestRemove();
      return;
    }
    _applyQuantity(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFCFCFC),
      padding: EdgeInsets.symmetric(
        vertical: AppDims.size_16.h,
        horizontal: AppDims.size_16.w,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppDims.size_16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Checkbox(
              checked: _line.selected,
              onTap: widget.syncing ? null : widget.onToggleSelected,
            ),
            SizedBox(width: AppDims.size_8.w),
            _buildImage(),
            SizedBox(width: AppDims.size_8.w),
            Expanded(child: _buildInfo(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final url = _line.data.imageUrl;
    return Container(
      width: 100.w,
      height: 100.w,
      decoration: BoxDecoration(
        color: AppColors.bareBackground,
        borderRadius: BorderRadius.circular(10.r),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      padding: EdgeInsets.all(AppDims.size_8.w),
      child: url == null || url.isEmpty
          ? Icon(Icons.image_outlined, size: 32.w, color: AppColors.gray400)
          : CachedNetworkImage(
              // แสดงด้วย imageurl ของ subproduct ก่อน
              imageUrl: url,
              fit: BoxFit.contain,
              errorWidget: (_, _, _) => CachedNetworkImage(
                // ถ้า error ใช้ main_image
                imageUrl: _line.data.product!.mainImageUrl.orEmpty,
                fit: BoxFit.contain,
                errorWidget: (_, _, _) => Icon(
                  Icons.image_outlined,
                  size: 32.w,
                  color: AppColors.gray400,
                ),
              ),
            ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final locale = context.languageCode;
    final product = _line.data.product;
    final productName = product?.getNameDisplay(locale);
    final name = (productName != null && productName.isNotEmpty)
        ? productName
        : (_line.data.productName ?? '');
    final variantName = _line.data.matchedSub?.getNameDisplay(locale);
    final variant = (variantName != null && variantName.isNotEmpty)
        ? variantName
        : (_line.data.variantName ?? '');
    final isFreeShipping = product?.isFreeShipping ?? false;
    final hasFlashSale = product?.hasFlashSale ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          name,
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: 16.sp,
            color: AppColors.darkBrown,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (variant.isNotEmpty)
          AppText(
            variant,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: 12.sp,
              color: AppColors.gray600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        // badge ส่งฟรี (is_free_shipping)
        if (isFreeShipping) ...[
          SizedBox(height: AppDims.size_4.h),
          _freeShippingBadge(context),
        ],
        SizedBox(height: AppDims.size_4.h),
        if (_line.data.unitCoinPrice != null) _buildCoinRow(context),
        SizedBox(height: 2.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _buildPrice(context)),
            _buildQtyStepper(context),
          ],
        ),
        // flash sale (has_flash_sale) — โลโก้ + นับถอยหลังเวลาหมดเขต
        if (hasFlashSale) ...[
          SizedBox(height: AppDims.size_4.h),
          _FlashSaleCountdown(endAt: product?.flashSaleEndsAt),
        ],
      ],
    );
  }

  /// Badge "ส่งฟรี" — pill gradient เหลือง→เขียว + ไอคอนกล่อง
  Widget _freeShippingBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDims.size_4.w,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.claimCoinButtonGradient,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icShop.icBox.image(
            width: 12.w,
            height: 12.w,
            color: AppColors.white,
          ),
          SizedBox(width: 2.w),
          AppText(
            context.wording.freeShipping,
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 10.sp,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinRow(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDims.size_4.w,
            vertical: 2.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.ci6,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.png.brownyCoin.image(width: 10.w, height: 10.w),
              SizedBox(width: AppDims.size_4.w),
              AppText(
                formatCurrency(
                  value: _line.unitCoinPrice,
                  trailingSign: ' ${context.wording.coin}',
                ),
                style: context.textTheme.labelSmall?.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrice(BuildContext context) {
    final hasDiscount = _line.lineMoneyDiscount > 0;
    final original = _line.data.matchedSub?.originalMoneyPrice;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          formatCurrency(value: _line.unitMoneyPrice, leadingSign: '฿'),
          style: context.textTheme.titleSmall?.copyWith(
            fontSize: 16.sp,
            color: AppColors.ci,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (hasDiscount && original != null) ...[
          SizedBox(width: AppDims.size_4.w),
          AppText(
            formatCurrency(value: original, leadingSign: '฿'),
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 12.sp,
              color: AppColors.gray500,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.gray500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQtyStepper(BuildContext context) {
    final enabled = !widget.syncing;
    final max = _stockMax;
    final atMax = max != null && _line.quantity >= max;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _qtyButton(
          icon: Icons.remove,
          enabled: enabled,
          onTap: _onDecrement,
        ),
        SizedBox(width: AppDims.size_8.w),
        SizedBox(
          width: 32.w,
          child: TextField(
            controller: _qtyController,
            enabled: enabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: context.textTheme.titleSmall?.copyWith(
              fontSize: 18.sp,
              color: AppColors.black.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            textInputAction: TextInputAction.done,
            onChanged: _onQuantityInput,
          ),
        ),
        SizedBox(width: AppDims.size_8.w),
        _qtyButton(
          icon: Icons.add,
          enabled: enabled && !atMax,
          onTap: _onIncrement,
        ),
      ],
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 18.w,
        height: 18.w,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.productStroke,
          borderRadius: BorderRadius.circular(2.r),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 12.w, color: AppColors.white),
      ),
    );
  }
}

/// แถว Flash Sale ในการ์ดสินค้า — โลโก้ Browny Flash + นับถอยหลัง HH:MM:SS
///
/// นับถอยหลังถึง [endAt] (flash_sale_ends_at) อัพเดททุก 1 วินาที
/// ครอบ [RepaintBoundary] กัน set|State ทุกวินาทีไปกระทบ list ทั้งหน้า
class _FlashSaleCountdown extends StatefulWidget {
  const _FlashSaleCountdown({required this.endAt});

  /// เวลาหมดเขต flash sale (ISO datetime string)
  final String? endAt;

  @override
  State<_FlashSaleCountdown> createState() => _FlashSaleCountdownState();
}

class _FlashSaleCountdownState extends State<_FlashSaleCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateRemaining();
    });
  }

  void _updateRemaining() {
    final end = DateTime.tryParse(widget.endAt ?? '');
    final diff = end?.difference(DateTime.now());
    setState(() {
      _remaining = (diff == null || diff.isNegative) ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _pad2(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final hh = _pad2(_remaining.inHours);
    final mm = _pad2(_remaining.inMinutes.remainder(60));
    final ss = _pad2(_remaining.inSeconds.remainder(60));
    return RepaintBoundary(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icShop.bronwyShopFlashSales.image(height: 14.h),
          SizedBox(width: AppDims.size_4.w),
          AppText(
            '$hh : $mm : $ss',
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 10.sp,
              color: AppColors.ci,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.checked, required this.onTap});

  final bool checked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 14.w,
        height: 14.w,
        decoration: BoxDecoration(
          color: checked ? AppColors.ci : AppColors.transparent,
          border: Border.all(color: AppColors.ci),
          borderRadius: BorderRadius.circular(2.r),
        ),
        alignment: Alignment.center,
        child: checked
            ? Icon(Icons.check, size: 10.w, color: AppColors.white)
            : null,
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.vm});

  final BrownyShopSelectedViewModel vm;

  @override
  Widget build(BuildContext context) {
    final canCheckout = vm.canCheckout;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: const [
          BoxShadow(color: Color(0x29000000), blurRadius: 4),
        ],
      ),
      padding: EdgeInsets.only(
        left: AppDims.size_16.w,
        right: AppDims.size_16.w,
        top: 6.h,
        bottom: AppDims.size_48.h,
      ),
      child: Row(
        children: [
          // เลือกทั้งหมด
          GestureDetector(
            onTap: () => vm.setAllSelected(!vm.isAllSelected),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Checkbox(
                  checked: vm.isAllSelected,
                  onTap: () => vm.setAllSelected(!vm.isAllSelected),
                ),
                SizedBox(width: AppDims.size_8.w),
                AppText(
                  context.wording.all,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.darkBrown,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    '${context.wording.total} : ',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  AppText(
                    formatCurrency(
                      value: vm.selectedMoneyTotal,
                      leadingSign: '฿',
                    ),
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.ci,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    '${context.wording.discount} : ',
                    style: context.textTheme.labelSmall?.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  AppText(
                    formatCurrency(
                      value: vm.selectedMoneyDiscount,
                      leadingSign: '฿',
                    ),
                    style: context.textTheme.labelSmall?.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(width: AppDims.size_14.w),
          GestureDetector(
            onTap: canCheckout
                ? () => BrownyShopSelected.goToPage(context, viewModel: vm)
                : null,
            child: Container(
              width: 101.w,
              height: AppDims.size_40.h,
              decoration: BoxDecoration(
                color: canCheckout ? AppColors.ci : AppColors.ctaPrimaryDisable,
                borderRadius: BorderRadius.circular(8.r),
              ),
              alignment: Alignment.center,
              child: AppText(
                '${context.wording.makePayment} (${vm.selectedCount})',
                style: context.textTheme.labelLarge?.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
