import 'package:browny_applications_new/core/data/remote/models/response/coupon_detail_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:flutter/material.dart';

/// SearchDelegate สำหรับค้นหาและเลือกสาขา (Store)
class StoreSearchDelegate extends SearchDelegate<PackageDetailData?> {
  final List<PackageDetailData> packages;
  final PackageDetailData? selectedPackage;

  StoreSearchDelegate({
    required this.packages,
    this.selectedPackage,
  }) : super(
         // เลือกสาขา (selectBranch) - TODO: Refactor to use context.wording
         searchFieldLabel: 'เลือกสาขา',
         keyboardType: TextInputType.text,
       );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.7)),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    // ปุ่มลบข้อความค้นหา
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // ปุ่มย้อนกลับ
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // แสดงผลลัพธ์การค้นหา
    final results = _filterPackages(context, query);
    return _buildPackageList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // แสดงคำแนะนำขณะพิมพ์
    final suggestions = _filterPackages(context, query);
    return _buildPackageList(context, suggestions);
  }

  /// กรองรายการสาขาตามคำค้นหา
  List<PackageDetailData> _filterPackages(
    BuildContext context,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) {
      return packages;
    }

    final locale = context.languageCode;
    final lowerQuery = searchQuery.toLowerCase();

    return packages.where((pkg) {
      final storeName = pkg.store?.name?.getByLocaleCode(locale) ?? '';
      final packageName = pkg.packageName?.getByLocaleCode(locale) ?? '';

      return storeName.toLowerCase().contains(lowerQuery) ||
          packageName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// สร้าง Widget list ของสาขา
  Widget _buildPackageList(
    BuildContext context,
    List<PackageDetailData> items,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              '\u0e44\u0e21\u0e48\u0e1e\u0e1a\u0e2a\u0e32\u0e02\u0e32\u0e17\u0e35\u0e48\u0e04\u0e49\u0e19\u0e2b\u0e32',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: AppColors.border,
      ),
      itemBuilder: (context, index) {
        final package = items[index];
        final isSelected = selectedPackage?.packageId == package.packageId;
        final locale = context.languageCode;
        final storeName = package.store?.name?.getByLocaleCode(locale) ?? '';
        final distance = package.store?.distanceMeters ?? '0';
        final distanceValue = double.tryParse(distance) ?? 0.0;
        final distanceDisplay = distanceValue >= 1000
            ? '${(distanceValue / 1000).toStringAsFixed(1)} km'
            : '${distanceValue.toStringAsFixed(0)} m';

        return ListTile(
          selected: isSelected,
          selectedTileColor: AppColors.ci3,
          leading: Icon(
            Icons.store,
            color: isSelected ? AppColors.primary : AppColors.gray600,
          ),
          title: Text(
            storeName,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            '\u0e23\u0e30\u0e22\u0e30\u0e2b\u0e48\u0e32\u0e07: $distanceDisplay',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.gray600,
            ),
          ),
          trailing: isSelected
              ? Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                )
              : null,
          onTap: () {
            close(context, package);
          },
        );
      },
    );
  }
}
