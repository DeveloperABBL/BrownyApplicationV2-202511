import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:browny_applications_new/feature/browny_shop/viewmodel/browny_shop_selected_viewmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

/// หน้าตะกร้าสินค้า Browny Shop
///
/// Figma: node 56:20258
/// ดึงตะกร้าจาก API ผ่าน [BrownyShopSelectedViewModel] (server เป็น source of truth)
/// การแก้จำนวนใช้ debounced batch sync — ดูคอมเมนต์ใน ViewModel
class BrownyShopSelected extends StatelessWidget {
  const BrownyShopSelected({super.key});

  static final pagePath = '/browny_shop_selected';
  static final pageName = 'BrownyShopSelected';

  static Future<T?> goToPage<T>(BuildContext context) async {
    return await context.pushNamed(BrownyShopSelected.pageName);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BrownyShopSelectedViewModel(
        context: context,
        repo: BrownyShopRepo(),
      ),
      child: const _BrownyShopSelectedWidget(),
    );
  }
}

class _BrownyShopSelectedWidget extends StatefulWidget {
  const _BrownyShopSelectedWidget();

  @override
  State<_BrownyShopSelectedWidget> createState() =>
      _BrownyShopSelectedWidgetState();
}

class _BrownyShopSelectedWidgetState extends State<_BrownyShopSelectedWidget> {
  BrownyShopSelectedViewModel? _vmRef;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<BrownyShopSelectedViewModel>();
      _vmRef = vm;
      vm.attachContext(context);
      vm.addListener(_onVmChanged);
      vm.loadCart();
    });
  }

  @override
  void dispose() {
    _vmRef?.removeListener(_onVmChanged);
    super.dispose();
  }

  /// surface sync error เป็น toast (อ่านครั้งเดียวแล้วเคลียร์)
  void _onVmChanged() {
    final vm = _vmRef;
    if (vm != null && vm.syncError) {
      vm.consumeSyncError();
      if (mounted) {
        AppOverlays.showToast(context, message: context.wording.errorUi);
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
    final confirmed = await AppOverlays.showBrownyDialog(
      context,
      message: context.wording.removeCartItemConfirm,
      confirmText: context.wording.confirm,
      cancelText: context.wording.cancel,
    );
    if (confirmed == true) {
      vm.removeLine(line);
    }
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
            Expanded(
              child: SizedBox(
                height: 100.w,
                child: _buildInfo(context),
              ),
            ),
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
              imageUrl: url,
              fit: BoxFit.contain,
              errorWidget: (_, _, _) => Icon(
                Icons.image_outlined,
                size: 32.w,
                color: AppColors.gray400,
              ),
            ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final locale = context.languageCode;
    final productName = _line.data.product?.getNameDisplay(locale);
    final name = (productName != null && productName.isNotEmpty)
        ? productName
        : (_line.data.productName ?? '');
    final variantName = _line.data.matchedSub?.getNameDisplay(locale);
    final variant = (variantName != null && variantName.isNotEmpty)
        ? variantName
        : (_line.data.variantName ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppText(
            name,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: 16.sp,
              color: AppColors.darkBrown,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
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
      ],
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
                ? () => debugPrint('tap checkout (TODO)')
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
