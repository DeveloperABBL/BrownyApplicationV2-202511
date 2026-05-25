import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/request/address_request.dart';
import 'package:browny_applications_new/core/data/remote/models/response/address_response.dart';
import 'package:browny_applications_new/feature/browny_shop/viewmodel/customer_ship_to_viewmodel.dart';
import 'package:browny_applications_new/feature/browny_shop/widgets/address_picker_bottom_sheet.dart';

/// โหมดของหน้า [ShipToDetailPage] — เพิ่มที่อยู่ใหม่ / แก้ไขที่อยู่เดิม
enum ShipToDetailMode { add, edit }

/// หน้าเพิ่ม/แก้ไขที่อยู่จัดส่ง
///
/// Figma: node 56:18423
/// เปิดจาก [CustomerShipToPage] — โหมดแยกด้วย [ShipToDetailMode]
/// (add = ฟอร์มเปล่า, edit = prefill จาก [address])
///
/// บันทึกผ่าน [CustomerShipToViewModel.saveAddress] (instance เดียวกับหน้า
/// รายการ — list จะ refresh อัตโนมัติ) แล้ว pop กลับ
///
/// TODO(figma): ช่อง "จังหวัด/เขต/รหัสไปรษณีย์/แขวง" เป็น tap field — picker
/// (showModalBottomSheet จังหวัด→เขต→แขวง) รอ Figma + API master ที่อยู่
class ShipToDetailPage extends StatefulWidget {
  const ShipToDetailPage({
    super.key,
    required this.mode,
    required this.viewModel,
    this.address,
  });

  static final pagePath = '/ship_to_detail';
  static final pageName = 'ShipToDetailPage';

  /// โหมด add / edit
  final ShipToDetailMode mode;

  /// VM ของหน้ารายการ — ใช้ saveAddress + ให้ list refresh เอง
  final CustomerShipToViewModel viewModel;

  /// ที่อยู่เดิม (ใช้ prefill ในโหมด edit)
  final AddressData? address;

  static Future<void> goToPage(
    BuildContext context, {
    required ShipToDetailMode mode,
    required CustomerShipToViewModel viewModel,
    AddressData? address,
  }) {
    return context.pushNamed(
      ShipToDetailPage.pageName,
      extra: (mode, viewModel, address),
    );
  }

  @override
  State<ShipToDetailPage> createState() => _ShipToDetailPageState();
}

class _ShipToDetailPageState extends State<ShipToDetailPage> {
  late final TextEditingController _nameController;
  // late final TextEditingController _roadController;
  late final TextEditingController _unitController;
  late final TextEditingController _noteController;
  late final TextEditingController _phoneController;

  /// ช่องที่อยู่ (จังหวัด/เขต/แขวง) — read-only, ค่ามาจาก picker
  late final TextEditingController _geoController;

  // ที่อยู่เชิงพื้นที่ — Th = ค่าส่ง API, En = แสดงผลคู่ในรูปแบบ "Th/En"
  // ค่า En จะมีเฉพาะตอน user เลือกจาก picker — edit prefill จาก API มีเฉพาะ Th
  String? _province;
  String? _provinceEn;
  String? _district;
  String? _districtEn;
  String? _subdistrict;
  String? _subdistrictEn;
  String? _zipcode;

  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _nameController = TextEditingController(text: a?.displayName ?? '');
    // _roadController = TextEditingController();
    _unitController = TextEditingController(text: a?.address ?? '');
    _noteController = TextEditingController(text: a?.note ?? '');
    _phoneController = TextEditingController(text: a?.phone ?? '');
    _province = a?.province;
    _district = a?.district;
    _subdistrict = a?.subdistrict;
    _zipcode = a?.zipcode;
    _geoController = TextEditingController(text: _geoText);
    _isDefault = a?.isDefaultAddress ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    // _roadController.dispose();
    _unitController.dispose();
    _noteController.dispose();
    _phoneController.dispose();
    _geoController.dispose();
    super.dispose();
  }

  /// ข้อความที่อยู่ที่เลือก — แสดงผล "Th/En" ถ้ามี En, ไม่มีก็ Th อย่างเดียว
  /// ลำดับ: จังหวัด, เขต/อำเภอ, รหัสไปรษณีย์, แขวง/ตำบล (ตาม label)
  String get _geoText {
    final parts = <String>[
      if ((_province ?? '').trim().isNotEmpty)
        _bilingual(_province, _provinceEn),
      if ((_district ?? '').trim().isNotEmpty)
        _bilingual(_district, _districtEn),
      if ((_subdistrict ?? '').trim().isNotEmpty)
        _bilingual(_subdistrict, _subdistrictEn),
      if ((_zipcode ?? '').trim().isNotEmpty) _zipcode!.trim(),
    ];
    return parts.join(', ');
  }

  /// รวมชื่อ Th + En ในรูปแบบ "Th/En" — ตัวใดว่างใช้อีกตัว
  String _bilingual(String? th, String? en) {
    final t = th?.trim() ?? '';
    final e = en?.trim() ?? '';
    if (t.isEmpty) return e;
    if (e.isEmpty) return t;
    return '$t/$e';
  }

  /// กรอกครบช่องบังคับ — ชื่อ / ถนน / เลขที่ / จังหวัด-เขต-แขวง-zip ครบ
  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      // _roadController.text.trim().isNotEmpty &&
      _unitController.text.trim().isNotEmpty &&
      (_province ?? '').trim().isNotEmpty &&
      (_district ?? '').trim().isNotEmpty &&
      (_subdistrict ?? '').trim().isNotEmpty &&
      (_zipcode ?? '').trim().isNotEmpty;

  /// เปิด BottomSheet เลือกที่อยู่ — เลือกครบจะ setState ค่า geo + อัปเดต field
  Future<void> _onPickAddress() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final picked = await AddressPickerBottomSheet.show(context);
    if (picked == null || !mounted) return;
    setState(() {
      _province = picked.province.nameTh;
      _provinceEn = picked.province.nameEn;
      _district = picked.district.nameTh;
      _districtEn = picked.district.nameEn;
      _subdistrict = picked.subdistrict.nameTh;
      _subdistrictEn = picked.subdistrict.nameEn;
      _zipcode = picked.subdistrict.zipCode;
      _geoController.text = _geoText;
    });
  }

  Future<void> _onSave() async {
    if (!_canSave) return;

    // แยกชื่อ-นามสกุลด้วยช่องว่างแรก (API ต้องการ first_name/last_name แยก)
    final name = _nameController.text.trim();
    final spaceIndex = name.indexOf(' ');
    final firstName = spaceIndex < 0 ? name : name.substring(0, spaceIndex);
    final lastName = spaceIndex < 0
        ? ''
        : name.substring(spaceIndex + 1).trim();
    final note = _noteController.text.trim();

    final body = AddressRequest(
      firstName: firstName,
      lastName: lastName,
      phone: _phoneController.text.trim(),
      zipcode: _zipcode ?? '',
      province: _province ?? '',
      district: _district ?? '',
      subdistrict: _subdistrict ?? '',
      // API มี address_line เดียว — รวมเลขที่ + ถนน/อาคาร
      addressLine: [
        _unitController.text.trim(),
        // _roadController.text.trim(),
      ].where((e) => e.isNotEmpty).join(' '),
      note: note.isEmpty ? null : note,
    );

    AppOverlays.showLoading(context);
    final result = await widget.viewModel.saveAddress(
      addressId: widget.mode == ShipToDetailMode.edit
          ? widget.address?.id
          : null,
      body: body,
      makeDefault: _isDefault,
    );
    if (!mounted) return;
    AppOverlays.hideLoading();

    if (result.isSuccess) {
      context.pop();
      // โหลดรายการใหม่ในหน้า list หลัง pop กลับ
      widget.viewModel.load();
    } else {
      AppOverlays.showBrownyDialog(context, message: context.wording.errorUi);
    }
  }

  /// ลบที่อยู่ — ยืนยันก่อนผ่าน dialog (ปุ่ม "ลบที่อยู่" สีแดงตาม design)
  void _onDelete() {
    final id = widget.address?.id;
    if (id == null) return;
    AppOverlays.showBrownyDialog(
      context,
      title: context.wording.deleteAddressTitle,
      message: context.wording.deleteAddressRecheck,
      confirmText: context.wording.deleteAddress,
      cancelText: context.wording.cancel,
      confirmColor: AppColors.error,
      cancelColor: AppColors.ci3,
      cancelTextColor: AppColors.ci,
      onConfirm: () => _confirmDelete(id),
    );
  }

  /// เรียก API ลบ — สำเร็จแล้ว pop กลับ แล้วค่อย load รายการใหม่
  Future<void> _confirmDelete(int id) async {
    AppOverlays.showLoading(context);
    final result = await widget.viewModel.deleteAddress(id);
    if (!mounted) return;
    AppOverlays.hideLoading();

    if (result.isSuccess) {
      context.pop();
      // หลัง pop กลับหน้า list แล้ว ค่อยโหลดรายการใหม่
      widget.viewModel.load();
    } else {
      AppOverlays.showBrownyDialog(context, message: context.wording.errorUi);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.darkBrown),
          title: AppText(
            context.wording.address,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: 18.sp,
              color: AppColors.darkBrown,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.all(AppDims.size_16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppDims.size_16.h,
            children: [
              _field(
                // ชื่อผู้รับสินค้า
                context,
                label: context.wording.recipientName,
                required: true,
                child: _textInput(
                  _nameController,
                  hint: context.wording.recipientNameHint,
                ),
              ),
              _field(
                // จังหวัด/เขต(อำเภอ)/รหัสไปรษณีย์/แขวง(ตำบล)
                context,
                label: context.wording.provinceDistrictZipSubdistrict,
                required: true,
                child: _tapInput(context),
              ),
              // _field(
              //   // ถนน/ชื่ออาคาร
              //   context,
              //   label: context.wording.roadBuilding,
              //   required: true,
              //   child: _textInput(_roadController),
              // ),
              _field(
                // เลขที่ยูนิต/ชั้น หรือบ้านเลขที่
                context,
                label: context.wording.unitFloorHouseNo,
                required: true,
                child: _textInput(_unitController),
              ),
              _field(
                // ข้อมูลที่อยู่เพิ่มเติม (ถ้ามี)
                context,
                label: context.wording.additionalAddressInfo,
                child: _textInput(_noteController),
              ),
              _field(
                // เบอร์โทรศัพท์มือถือ
                context,
                label: context.wording.mobilePhone,
                child: _textInput(
                  _phoneController,
                  hint: '+66',
                  keyboardType: TextInputType.phone,
                ),
              ),
              _defaultCheckbox(context),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  /// 1 field group — label (+ * ถ้าบังคับ) + input
  Widget _field(
    BuildContext context, {
    required String label,
    required Widget child,
    bool required = false,
  }) {
    final labelStyle = context.textTheme.titleSmall?.copyWith(
      fontSize: 14.sp,
      color: AppColors.darkBrown,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: labelStyle,
            children: [
              TextSpan(text: label),
              if (required)
                TextSpan(
                  text: ' *',
                  style: labelStyle?.copyWith(color: AppColors.error),
                ),
            ],
          ),
        ),
        SizedBox(height: AppDims.size_8.h),
        child,
      ],
    );
  }

  /// ช่องกรอกข้อความ — ใช้ [AppTextFormField] (สไตล์/ความสูงตาม theme กลาง)
  Widget _textInput(
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
  }) {
    return AppTextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: context.inputTextStyle.copyWith(color: AppColors.gray500),
        fillColor: AppColors.background,
        prefixIcon: const SizedBox.shrink(),
      ),
    );
  }

  /// ช่องที่อยู่ (จังหวัด/เขต/แขวง) — read-only แตะเปิด picker
  ///
  /// `maxLines: null` ให้ field ขยายความสูงตามข้อความ — user เห็นข้อมูลเต็ม
  /// ทุกบรรทัด (ไม่ ellipsis เหมือนใน design)
  Widget _tapInput(BuildContext context) {
    return AppTextFormField(
      controller: _geoController,
      readOnly: true,
      onTap: _onPickAddress,
      maxLines: null,
      decoration: InputDecoration(
        hintText: context.wording.deliveryAddressHint,
        hintStyle: context.inputTextStyle.copyWith(color: AppColors.gray500),
        fillColor: AppColors.background,
        prefixIcon: const SizedBox.shrink(),
      ),
    );
  }

  /// checkbox "ตั้งเป็นที่อยู่หลัก"
  Widget _defaultCheckbox(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isDefault = !_isDefault),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 16.w,
            height: 16.w,
            decoration: BoxDecoration(
              color: _isDefault ? AppColors.ci : AppColors.transparent,
              border: Border.all(color: AppColors.ci),
              borderRadius: BorderRadius.circular(2.r),
            ),
            alignment: Alignment.center,
            child: _isDefault
                ? Icon(Icons.check, size: 12.w, color: AppColors.white)
                : null,
          ),
          SizedBox(width: AppDims.size_8.w),
          AppText(
            context.wording.setAsMainAddress,
            style: context.textTheme.titleSmall?.copyWith(
              fontSize: 14.sp,
              color: AppColors.darkBrown,
            ),
          ),
        ],
      ),
    );
  }

  /// แถบล่าง — ปุ่ม "บันทึกที่อยู่" + ปุ่ม "ลบที่อยู่" (เฉพาะโหมดแก้ไข)
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: Color(0x33928B8B), blurRadius: 16, spreadRadius: 8),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppDims.size_16.w,
        AppDims.size_16.h,
        AppDims.size_24.w,
        AppDims.size_16.h,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ปุ่มบันทึกที่อยู่ — กดได้เมื่อกรอกช่องบังคับครบ
            ListenableBuilder(
              listenable: Listenable.merge([
                _nameController,
                // _roadController,
                _unitController,
              ]),
              builder: (context, _) {
                final enabled = _canSave;
                return GestureDetector(
                  onTap: enabled ? _onSave : null,
                  child: Container(
                    width: double.infinity,
                    height: AppDims.size_40.h,
                    decoration: BoxDecoration(
                      color: enabled
                          ? AppColors.ci
                          : AppColors.ctaPrimaryDisable,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    alignment: Alignment.center,
                    child: AppText(
                      context.wording.saveAddress,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
            // ปุ่มลบที่อยู่ — แสดงเฉพาะตอนแก้ไขที่อยู่เดิม
            if (widget.mode == ShipToDetailMode.edit) ...[
              SizedBox(height: AppDims.size_16.h),
              GestureDetector(
                onTap: _onDelete,
                child: Container(
                  width: double.infinity,
                  height: AppDims.size_40.h,
                  decoration: BoxDecoration(
                    color: AppColors.ci3,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: AppText(
                    context.wording.deleteAddress,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.ci,
                    ),
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
