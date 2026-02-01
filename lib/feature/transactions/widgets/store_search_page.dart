import 'package:browny_applications_new/core/data/remote/models/response/coupon_detail_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:browny_applications_new/feature/transactions/models/store_search_history.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:browny_applications_new/res/icons/assets.gen.dart';
import 'package:browny_applications_new/res/strings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget สำหรับค้นหาและเลือกสาขา
class StoreSearchPage extends StatefulWidget {
  final List<PackageDetailData> packages;
  final PackageDetailData? selectedPackage;
  final Function(PackageDetailData?) onPackageSelected;

  const StoreSearchPage({
    super.key,
    required this.packages,
    this.selectedPackage,
    required this.onPackageSelected,
  });

  @override
  State<StoreSearchPage> createState() => _StoreSearchPageState();
}

class _StoreSearchPageState extends State<StoreSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<StoreSearchHistory> _searchHistory = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final history = await StoreSearchHistoryHelper.getHistory();
    setState(() {
      _searchHistory = history;
    });
  }

  Future<void> _saveToHistory(PackageDetailData package) async {
    final locale = context.languageCode;
    final history = StoreSearchHistory(
      packageId: package.packageId ?? 0,
      storeId: package.store?.id,
      storeName: package.store?.name?.getByLocaleCode(locale) ?? '',
      packageName: package.packageName?.getByLocaleCode(locale) ?? '',
      groupOption: package.groupOption?.getByLocaleCode(locale),
      distance: package.store?.distanceMeters,
    );

    await StoreSearchHistoryHelper.saveHistory(history);
    await _loadSearchHistory();
  }

  /// กรองรายการสาขาตามคำค้นหา
  List<PackageDetailData> _getFilteredPackages() {
    if (_searchQuery.isEmpty) {
      return widget.packages;
    }

    final locale = context.languageCode;
    final lowerQuery = _searchQuery.toLowerCase();

    return widget.packages.where((pkg) {
      final storeName = pkg.store?.name?.getByLocaleCode(locale) ?? '';
      final packageName = pkg.packageName?.getByLocaleCode(locale) ?? '';
      final groupOption = pkg.groupOption?.getByLocaleCode(locale) ?? '';

      return storeName.toLowerCase().contains(lowerQuery) ||
          packageName.toLowerCase().contains(lowerQuery) ||
          groupOption.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// จัดกลุ่มข้อมูลตาม groupOption
  Map<String, List<PackageDetailData>> _groupPackagesByOption(
    List<PackageDetailData> packages,
  ) {
    final locale = context.languageCode;
    final grouped = <String, List<PackageDetailData>>{};

    for (final package in packages) {
      final groupKey = package.groupOption?.getByLocaleCode(locale) ?? 'อื่นๆ';
      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = [];
      }
      grouped[groupKey]!.add(package);
    }

    return grouped;
  }

  void _onPackageSelect(PackageDetailData package) async {
    await _saveToHistory(package);
    widget.onPackageSelected(package);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: AppColors.gray600),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Header with close button
              Align(
                alignment: AlignmentGeometry.centerLeft,
                child: AppText(
                  'เลือกสาขา',
                  style: context.textTheme.labelLarge!.copyWith(
                    fontSize: AppDims.size_16.sp,
                  ),
                ),
              ),
              AppDims.vericalPadding_4,

              // Search Bar
              AppTextFormField(
                controller: _searchController,
                style: context.textTheme.labelLarge!.copyWith(
                  fontSize: AppDims.size_14.sp,
                  color: AppColors.gray600,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: context.wording.searchStoreParticipating,
                  prefixIcon: SizedBox.shrink(),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: AppColors.gray600),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              AppDims.vericalPadding_8,

              // Content
              Expanded(
                child: _searchQuery.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDims.size_8,
                        ),
                        child: _buildHistorySection(),
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDims.size_8,
                        ),
                        child: _buildSearchResults(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// แสดงประวัติการค้นหา
  Widget _buildHistorySection() {
    if (_searchHistory.isEmpty) {
      return _buildSearchResults(); // แสดงรายการทั้งหมดถ้าไม่มีประวัติ
    }

    return ListView(
      children: [
        // รายการประวัติ
        ..._searchHistory.map((history) {
          // หา package ที่ตรงกับ history
          final package = widget.packages.firstWhere(
            (p) => p.packageId == history.packageId,
            orElse: () => PackageDetailData(),
          );

          if (package.packageId == null) {
            return SizedBox.shrink();
          }

          return _buildPackageItem(
            package: package,
            storeName: history.storeName,
            distance: history.distance,
            isHistory: true,
          );
        }),

        Divider(
          height: 1,
          color: AppColors.border,
        ),

        _buildSearchResults(showTitle: false),
      ],
    );
  }

  /// แสดงผลลัพธ์การค้นหา
  Widget _buildSearchResults({bool showTitle = false}) {
    final filteredPackages = _getFilteredPackages();

    if (filteredPackages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64.w, color: AppColors.gray500),
            SizedBox(height: 16.h),
            AppText(
              context.wording.storeNotFound,
              style: context.textTheme.bodyMedium!.copyWith(
                fontSize: AppDims.size_14.sp,
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
      );
    }

    final groupedPackages = _groupPackagesByOption(filteredPackages);
    final locale = context.languageCode;

    return ListView(
      shrinkWrap: _searchQuery.isEmpty,
      physics: _searchQuery.isEmpty ? NeverScrollableScrollPhysics() : null,
      children: groupedPackages.entries.map((entry) {
        final groupName = entry.key;
        final packages = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Title
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: AppText(
                groupName,
                style: context.textTheme.labelLarge!.copyWith(
                  fontSize: AppDims.size_16.sp,
                  color: AppColors.gray600,
                ),
              ),
            ),

            // Group Items
            ...packages.map((package) {
              final storeName =
                  package.store?.name?.getByLocaleCode(locale) ?? '';
              final distance = package.store?.distanceMeters;

              return _buildPackageItem(
                package: package,
                storeName: storeName,
                distance: distance,
              );
            }),

            Divider(
              height: 1,
              color: AppColors.border,
            ),
          ],
        );
      }).toList(),
    );
  }

  /// สร้าง Widget สำหรับแต่ละ package item
  Widget _buildPackageItem({
    required PackageDetailData package,
    required String storeName,
    String? distance,
    bool isHistory = false,
  }) {
    // final isSelected = widget.selectedPackage?.packageId == package.packageId;
    // final distanceValue = double.tryParse(distance ?? '0') ?? 0.0;
    // final distanceDisplay = distance != null && distance.isNotEmpty
    //     ? (distanceValue >= 1000
    //           ? '${(distanceValue / 1000).toStringAsFixed(1)} กม.'
    //           : '${distanceValue.toStringAsFixed(0)} ม.')
    //     : '';

    return InkWell(
      onTap: () => _onPackageSelect(package),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppDims.size_12.h),
        child: Row(
          children: [
            // History Icon
            if (isHistory) ...[
              Assets.svg.icRefresh.svg(),
              SizedBox(width: 12.w),
            ],

            // Store Name and Distance
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    storeName,
                    style: context.textTheme.bodyMedium!.copyWith(
                      fontSize: AppDims.size_16.sp,
                      color: AppColors.gray600,
                    ),
                  ),
                  if (package.store!.distanceMeters.orEmpty.isNotEmpty) ...[
                    AppDims.vericalPadding_4,

                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14.w,
                          color: AppColors.gray600,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          package.store!.getDistaceDisplay(
                            context.languageCode,
                          ),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // History badge
            if (isHistory) ...[
              Container(
                padding: EdgeInsets.all(AppDims.size_4),
                decoration: BoxDecoration(
                  color: AppColors.bareBackground,
                  borderRadius: BorderRadius.circular(AppDims.size_4.r),
                ),
                child: AppText(
                  context.wording.recent,
                  style: context.textTheme.labelMedium!.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
