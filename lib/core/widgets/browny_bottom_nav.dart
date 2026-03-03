import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/feature/home/screens/home_page.dart';
import 'package:browny_applications_new/feature/map/screens/map_page.dart';
import 'package:browny_applications_new/feature/scaner/screen/scanner_page.dart';
import 'package:browny_applications_new/feature/transactions/screens/coupons_evoucher/coupon_voucher_page.dart';

/// BrownyBottomNav - Navigation Bar แบบกำหนดเองสำหรับแอป Browny
///
/// วิดเจ็ตที่ใช้สำหรับแสดง Bottom Navigation แบบลอยตัว มีปุ่มกลางยกสูง
/// รองรับการใช้งานคล้าย BottomNavigationBar มาตรฐานของ Flutter
///
/// พารามิเตอร์หลัก (คล้าย BottomNavigationBar):
/// - items: รายการปุ่ม navigation (List BottomNavigationBarItem)
/// - currentIndex: ตำแหน่งปุ่มที่เลือกอยู่
/// - onTap: ฟังก์ชันที่เรียกเมื่อกดปุ่ม (รับ index ของปุ่ม)
///
/// พารามิเตอร์เพิ่มเติม:
/// - onCenterTap: ฟังก์ชันสำหรับปุ่มกลาง (ถ้ามีจะแสดงปุ่มลอยตัวตรงกลาง)
/// - centerIcon: ไอคอนของปุ่มกลาง (ค่าเริ่มต้น: Icons.qr_code_scanner)
/// - centerIndex: ตำแหน่งที่จะสำรองไว้สำหรับปุ่มกลาง (ค่าเริ่มต้น: ตรงกลาง)
/// - showLabels: แสดงข้อความใต้ไอคอนหรือไม่ (ค่าเริ่มต้น: true)
/// - backgroundRadius, centerSize, margin: ปรับแต่งรูปแบบการแสดงผล

typedef OnBrownyBottomNavTab = Function(BuildContext context, int index);

class BrownyBottomNav extends StatefulWidget {
  const BrownyBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onCenterTap,
    this.centerIcon,
    this.centerIndex,
    this.showLabels = true,
    this.backgroundRadius = 32.0,
    this.centerSize = 64.0,
    this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 16),
  });

  final int currentIndex; // ตำแหน่งปุ่มที่เลือกอยู่
  final OnBrownyBottomNavTab onTap; // ฟังก์ชันเมื่อกดปุ่ม

  /// ฟังก์ชันสำหรับปุ่มกลาง - ถ้ากำหนดค่าจะแสดงปุ่มลอยตัวพร้อม gradient
  final VoidCallback? onCenterTap;
  final Widget? centerIcon; // ไอคอนของปุ่มกลาง

  /// ตำแหน่งที่จะสำรองไว้สำหรับปุ่มกลาง (ค่าเริ่มต้น: ตรงกลาง)
  final int? centerIndex;

  /// แสดงข้อความใต้ไอคอนหรือไม่
  final bool showLabels;

  /// ตัวแปรสำหรับปรับแต่งรูปแบบการแสดงผล
  final double backgroundRadius; // รัศมีมุมของพื้นหลัง
  final double centerSize; // ขนาดปุ่มกลาง
  final EdgeInsets margin;
  @override
  State<BrownyBottomNav> createState() => _BrownyBottomNavState();

  static onTapAppDefault(BuildContext context, int index) {
    if (index == 0) {
      context.pushNamedAndClear(HomePage.pageName);
      return;
    }

    if (index == 1) {
      // context.pushNamed(CouponVoucherPage.pageName);
      CouponVoucherPage.goToPage(
        context,
      );
      return;
    }

    if (index == 2) {
      context.pushNamed(MapPage.pageName);
      return;
    }
  }
}

class _BrownyBottomNavState extends State<BrownyBottomNav> {
  late List<BottomNavigationBarItem> items;
  // ระยะขอบของ navigation bar
  @override
  Widget build(BuildContext context) {
    items = [
      BottomNavigationBarItem(
        icon: Assets.svg.icHome.svg(),
        activeIcon: Assets.svg.icHomeActive.svg(),
        label: context.wording.home,
      ),
      BottomNavigationBarItem(
        icon: Assets.svg.icTicket.svg(),
        activeIcon: Assets.svg.icTicketActive.svg(),
        label: context.wording.rewards,
      ),
      BottomNavigationBarItem(
        icon: Assets.svg.icBranch.svg(),
        activeIcon: Assets.svg.icBranchActive.svg(),
        label: context.wording.branch,
      ),
      BottomNavigationBarItem(
        icon: Assets.svg.icShop.svg(
          colorFilter: ColorFilter.mode(
            AppColors.gray500,
            BlendMode.srcIn,
          ),
        ),
        activeIcon: Assets.svg.icShopActive.svg(),
        label: context.wording.shop,
      ),
    ];
    VoidCallback mOnCenterTap =
        widget.onCenterTap ??
        () {
          // Default ไปหน้า Scan
          ScannerPage.goToPage(
            context,
            initialIndex: 0,
          );
        };
    // final hasCenter = mOnCenterTap != null;
    final int cIndex = widget.centerIndex ?? (items.length ~/ 2);

    // สร้างรายการ widget ของแต่ละปุ่ม พร้อมสำรองพื้นที่สำหรับปุ่มกลาง
    List<Widget> itemWidgets = [];
    for (int i = 0; i < items.length; i++) {
      if (i == cIndex) {
        // สำรองพื้นที่ว่างไว้ใต้ปุ่มกลางที่ยกสูง
        itemWidgets.add(const SizedBox(width: 0));
      }
      final bool selected = i == widget.currentIndex;
      final item = items[i];
      bool enable = item.label != context.wording.shop;
      itemWidgets.add(
        _NavItem(
          icon: selected ? item.activeIcon : item.icon,
          label: item.label ?? '',
          selected: selected,
          showLabel: widget.showLabels,
          enable: enable,
          onTap: () => widget.onTap(context, i),
        ),
      );
    }

    return SafeArea(
      // bottom: false,
      // maintainBottomViewPadding: true,
      minimum: EdgeInsets.only(bottom: AppDims.size_12.h),
      child: SizedBox(
        height: _barHeight(true),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // พื้นหลังของ navigation bar
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: widget.margin,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(
                      widget.backgroundRadius,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _ItemsRow(
                    hasCenter: true,
                    children: _withCenterSpacer(
                      itemWidgets,
                      true,
                      cIndex,
                    ),
                  ),
                ),
              ),
            ),

            // ปุ่มกลางที่ยกสูง
            // if (hasCenter)
            Positioned(
              bottom: _centerBottomOffset(),
              child: GestureDetector(
                onTap: mOnCenterTap,
                child: Builder(
                  builder: (context) {
                    double width = 106.w;
                    double height = 100.h;
                    switch (context.languageCode) {
                      case 'zh':
                        return Assets.svg.scanIconZh.svg(
                          width: width,
                          height: height,
                        );
                      case 'en':
                        return Assets.svg.scanIconEn.svg(
                          width: width,
                          height: height,
                        );
                      default:
                        return Assets.svg.scanIcon.svg(
                          width: width,
                          height: height,
                        );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _barHeight(bool hasCenter) {
    // ความสูงพื้นฐาน + พื้นที่เพิ่มเติมสำหรับปุ่มกลางที่ยกสูง
    return 82;
  }

  double _centerBottomOffset() {
    // ยกปุ่มกลางขึ้นเหนือ navigation bar
    return (widget.margin.bottom);
  }

  List<Widget> _withCenterSpacer(
    List<Widget> children,
    bool hasCenter,
    int cIndex,
  ) {
    if (!hasCenter) return children;

    // เพิ่มช่องว่างรอบตำแหน่งปุ่มกลาง เพื่อไม่ให้ทับกับปุ่มที่ยกสูง
    final List<Widget> result = [];
    int visualIndex = 0;
    for (int i = 0; i < children.length; i++) {
      final w = children[i];
      if (visualIndex == cIndex) {
        // เพิ่ม spacer ยืดหยุ่นใต้ปุ่มกลางเพื่อให้ layout สมดุล
        result.add(
          const Expanded(
            child: SizedBox.shrink(),
          ),
        );
      }
      result.add(Expanded(child: Center(child: w)));
      visualIndex++;
    }
    return result;
  }
}

/// Widget สำหรับแสดงแถวของปุ่ม navigation
class _ItemsRow extends StatelessWidget {
  const _ItemsRow({required this.children, required this.hasCenter});

  final List<Widget> children;
  final bool hasCenter;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    );
  }
}

/// Widget สำหรับแสดงปุ่ม navigation แต่ละปุ่ม
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.showLabel,
    required this.onTap,
    this.enable = true,
  });

  final Widget icon;
  final String label;
  final bool selected;
  final bool showLabel;
  final bool enable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool canShowLabel =
            showLabel && label.trim().isNotEmpty && constraints.maxHeight >= 48;
        final Color iconColor = enable
            ? (selected ? AppColors.primary : AppColors.textSecondary)
            : AppColors.gray500;
        final double iconSize = canShowLabel ? 24 : 28;

        Widget iconWidget = IconTheme(
          data: IconThemeData(color: iconColor, size: iconSize),
          child: icon,
        );

        return Material(
          color: AppColors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(32),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: canShowLabel ? 4 : 6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconWidget,
                  if (canShowLabel) const SizedBox(height: 2),
                  if (canShowLabel)
                    AppText(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelSmall!.copyWith(
                        fontSize: 10.sp,
                        height: 1.1,
                        letterSpacing: 0.3,
                        color: enable ? AppColors.primary : AppColors.gray500,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
