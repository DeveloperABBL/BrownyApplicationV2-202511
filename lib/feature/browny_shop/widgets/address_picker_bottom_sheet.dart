import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/address_master_response.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/address_repo.dart';

/// ผลลัพท์ที่ AddressPickerBottomSheet คืนกลับ — จังหวัด + อำเภอ + ตำบล (มี zip)
typedef PickedAddress = ({
  ProvinceData province,
  DistrictData district,
  SubdistrictData subdistrict,
});

/// BottomSheet เลือกที่อยู่แบบ cascade: จังหวัด → อำเภอ → ตำบล
///
/// Figma: node 56:18571 / 56:18979
///
/// Usage:
/// ```
/// final picked = await AddressPickerBottomSheet.show(context);
/// if (picked != null) { ... use picked.province / .district / .subdistrict }
/// ```
class AddressPickerBottomSheet extends StatefulWidget {
  const AddressPickerBottomSheet._();

  /// แสดง BottomSheet — คืน [PickedAddress] เมื่อเลือกถึงตำบล, null ถ้าปิด
  static Future<PickedAddress?> show(BuildContext context) {
    return showModalBottomSheet<PickedAddress>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => const AddressPickerBottomSheet._(),
    );
  }

  @override
  State<AddressPickerBottomSheet> createState() =>
      _AddressPickerBottomSheetState();
}

enum _PickerStep { province, district, subdistrict }

class _AddressPickerBottomSheetState extends State<AddressPickerBottomSheet> {
  final _repo = AddressRepo();
  final _searchController = TextEditingController();

  _PickerStep _step = _PickerStep.province;

  // โหลด list ตามขั้น — โหลด lazy เมื่อขึ้น step นั้น
  UiResult<List<ProvinceData>> _provinces = UiResult.loading();
  UiResult<List<DistrictData>> _districts = UiResult.loading();
  UiResult<List<SubdistrictData>> _subdistricts = UiResult.loading();

  // เลือกแล้วเก็บไว้สำหรับ breadcrumb + ส่งคืนตอนจบ
  ProvinceData? _selectedProvince;
  DistrictData? _selectedDistrict;

  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ========== Load (lazy ตาม step) ==========

  Future<void> _loadProvinces() async {
    setState(() => _provinces = UiResult.loading());
    final r = await _repo.fetchProvinces();
    if (!mounted) return;
    setState(() {
      _provinces = r.isSuccess
          ? UiResult.success(data: r.data)
          : UiResult.error(error: r.error);
    });
  }

  Future<void> _loadDistricts(int provinceId) async {
    setState(() => _districts = UiResult.loading());
    final r = await _repo.fetchDistricts(provinceId: provinceId);
    if (!mounted) return;
    setState(() {
      _districts = r.isSuccess
          ? UiResult.success(data: r.data)
          : UiResult.error(error: r.error);
    });
  }

  Future<void> _loadSubdistricts(int districtId) async {
    setState(() => _subdistricts = UiResult.loading());
    final r = await _repo.fetchSubdistricts(districtId: districtId);
    if (!mounted) return;
    setState(() {
      _subdistricts = r.isSuccess
          ? UiResult.success(data: r.data)
          : UiResult.error(error: r.error);
    });
  }

  // ========== Step navigation ==========

  void _onPickProvince(ProvinceData p) {
    final id = p.id;
    if (id == null) return;
    setState(() {
      _selectedProvince = p;
      _selectedDistrict = null;
      _step = _PickerStep.district;
      _searchController.clear();
      _searchText = '';
    });
    _loadDistricts(id);
  }

  void _onPickDistrict(DistrictData d) {
    final id = d.id;
    if (id == null) return;
    setState(() {
      _selectedDistrict = d;
      _step = _PickerStep.subdistrict;
      _searchController.clear();
      _searchText = '';
    });
    _loadSubdistricts(id);
  }

  void _onPickSubdistrict(SubdistrictData s) {
    final province = _selectedProvince;
    final district = _selectedDistrict;
    if (province == null || district == null) return;
    Navigator.of(context).pop<PickedAddress>(
      (province: province, district: district, subdistrict: s),
    );
  }

  void _onBack() {
    setState(() {
      _searchController.clear();
      _searchText = '';
      if (_step == _PickerStep.subdistrict) {
        _step = _PickerStep.district;
      } else if (_step == _PickerStep.district) {
        _step = _PickerStep.province;
      }
    });
  }

  // ========== Build ==========

  @override
  Widget build(BuildContext context) {
    // ขนาด: 80% ของจอ (ดู design — ใกล้เต็มจอ)
    final height = MediaQuery.of(context).size.height * 0.85;
    return SafeArea(
      top: false,
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDims.size_16.w,
                AppDims.size_8.h,
                AppDims.size_16.w,
                AppDims.size_8.h,
              ),
              child: _buildSearchField(context),
            ),
            if (_selectedProvince != null) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
                child: _buildBreadcrumb(context),
              ),
              SizedBox(height: AppDims.size_8.h),
            ],
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDims.size_16.w,
                AppDims.size_8.h,
                AppDims.size_16.w,
                AppDims.size_8.h,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppText(
                  _stepTitle(context),
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.darkBrown,
                  ),
                ),
              ),
            ),
            Expanded(child: _buildList(context)),
          ],
        ),
      ),
    );
  }

  String _stepTitle(BuildContext context) {
    switch (_step) {
      case _PickerStep.province:
        return context.wording.selectProvince;
      case _PickerStep.district:
        return context.wording.selectDistrict;
      case _PickerStep.subdistrict:
        return context.wording.selectSubdistrict;
    }
  }

  /// Header — back (ซ่อนที่ step province) + title + close
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDims.size_8.w,
        vertical: AppDims.size_8.h,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40.w,
            child: _step == _PickerStep.province
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: _onBack,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.chevron_left,
                      size: 28.w,
                      color: AppColors.darkBrown,
                    ),
                  ),
          ),
          Expanded(
            child: AppText(
              context.wording.address,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                fontSize: 16.sp,
                color: AppColors.darkBrown,
              ),
            ),
          ),
          SizedBox(
            width: 40.w,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.close,
                size: 24.w,
                color: AppColors.darkBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ช่องค้นหา — filter รายการทาง client-side (name_th หรือ name_en)
  ///
  /// Figma node 56:18588 — bg gray50 + เส้นขอบ border 1px, radius 8
  Widget _buildSearchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppDims.size_16.w,
        vertical: AppDims.size_4.h,
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 16.w, color: AppColors.gray500),
          SizedBox(width: AppDims.size_8.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchText = v),
              style: context.inputTextStyle,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: AppDims.size_8.h,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ช่องสรุปสิ่งที่เลือกไปแล้ว — โผล่หลังเลือกจังหวัด
  ///
  /// Figma node 56:18887 — bg #F5F5F5 (grey-150), padding 16h × 8v, radius 8
  Widget _buildBreadcrumb(BuildContext context) {
    final parts = <String>[
      if (_selectedProvince != null)
        _bilingual(_selectedProvince!.nameTh, _selectedProvince!.nameEn),
      if (_selectedDistrict != null)
        _bilingual(_selectedDistrict!.nameTh, _selectedDistrict!.nameEn),
    ];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppDims.size_16.w,
        vertical: AppDims.size_8.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputFieldDefaultBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: AppText(
        parts.join(' '),
        style: context.textTheme.titleSmall?.copyWith(
          fontSize: 14.sp,
          color: AppColors.darkBrown,
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    switch (_step) {
      case _PickerStep.province:
        return _buildResultList<ProvinceData>(
          result: _provinces,
          filter: (e) => _matchSearch(e.nameTh, e.nameEn),
          label: (e) => _bilingual(e.nameTh, e.nameEn),
          onTap: _onPickProvince,
          onRetry: _loadProvinces,
        );
      case _PickerStep.district:
        return _buildResultList<DistrictData>(
          result: _districts,
          filter: (e) => _matchSearch(e.nameTh, e.nameEn),
          label: (e) => _bilingual(e.nameTh, e.nameEn),
          onTap: _onPickDistrict,
          onRetry: () {
            final id = _selectedProvince?.id;
            if (id != null) _loadDistricts(id);
          },
        );
      case _PickerStep.subdistrict:
        return _buildResultList<SubdistrictData>(
          result: _subdistricts,
          filter: (e) =>
              _matchSearch(e.nameTh, e.nameEn) ||
              (e.zipCode?.contains(_searchText.trim()) ?? false),
          label: (e) => _bilingual(e.nameTh, e.nameEn),
          onTap: _onPickSubdistrict,
          onRetry: () {
            final id = _selectedDistrict?.id;
            if (id != null) _loadSubdistricts(id);
          },
        );
    }
  }

  Widget _buildResultList<T>({
    required UiResult<List<T>> result,
    required bool Function(T) filter,
    required String Function(T) label,
    required void Function(T) onTap,
    required VoidCallback onRetry,
  }) {
    if (result.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (result.isError) {
      return Center(
        child: GestureDetector(
          onTap: onRetry,
          behavior: HitTestBehavior.opaque,
          child: AppText(context.wording.errorUi),
        ),
      );
    }
    final all = result.data ?? const [];
    final filtered = _searchText.trim().isEmpty
        ? all
        : all.where(filter).toList();
    if (filtered.isEmpty) {
      return Center(
        child: AppText(
          context.wording.dataNotFound,
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.gray500,
          ),
        ),
      );
    }
    return ListView.separated(
      physics: const ClampingScrollPhysics(),
      itemCount: filtered.length,
      padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
      separatorBuilder: (_, _) => Divider(
        height: 1,
        thickness: 1,
        color: AppColors.background,
      ),
      itemBuilder: (_, i) {
        final item = filtered[i];
        return InkWell(
          onTap: () => onTap(item),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: AppDims.size_14.h),
            child: AppText(
              label(item),
              style: context.textTheme.titleSmall?.copyWith(
                fontSize: 14.sp,
                color: AppColors.darkBrown,
              ),
            ),
          ),
        );
      },
    );
  }

  // ========== Helpers ==========

  /// รวมชื่อไทย/อังกฤษเป็น "Th/En" (ตามดีไซน์) — ตัวใดว่างจะใช้อีกตัว
  String _bilingual(String? th, String? en) {
    final t = th?.trim() ?? '';
    final e = en?.trim() ?? '';
    if (t.isEmpty) return e;
    if (e.isEmpty) return t;
    return '$t/$e';
  }

  /// match กับ search text — เทียบทั้ง th + en (case-insensitive)
  bool _matchSearch(String? th, String? en) {
    final q = _searchText.trim().toLowerCase();
    if (q.isEmpty) return true;
    final t = th?.toLowerCase() ?? '';
    final e = en?.toLowerCase() ?? '';
    return t.contains(q) || e.contains(q);
  }
}
