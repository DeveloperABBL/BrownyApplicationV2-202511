import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:browny_applications_new/res/icons/assets.gen.dart';
import 'package:browny_applications_new/res/styles/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Model สำหรับ Dropdown Item ที่รองรับ Generic Type
class DropdownCustomItem<T> {
  final T value;
  final String label;
  final bool selectable;
  final Widget? labelWidget;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  const DropdownCustomItem({
    required this.value,
    required this.label,
    this.selectable = true,
    this.leadingIcon,
    this.labelWidget,
    this.trailingIcon,
  });
}

class CustomDropdown<T> extends StatefulWidget {
  final List<DropdownCustomItem<T>> items;
  final String hint;
  final ValueChanged<T?>? onChanged;
  final T? selectedValue;
  final VoidCallback? onNoItemsFound;
  final VoidCallback? onLocationTap;
  final bool isInteractive;
  final bool showDisableDecoration;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.hint,
    this.onChanged,
    this.selectedValue,
    this.onNoItemsFound,
    this.onLocationTap,
    this.isInteractive = true,
    this.showDisableDecoration = false,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  bool _isOpen = false;
  T? _selectedValue;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<DropdownCustomItem<T>> get _filteredItems {
    if (_searchQuery.isEmpty) {
      return widget.items;
    }
    return widget.items
        .where(
          (item) =>
              item.label.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  String get _selectedLabel {
    if (_selectedValue == null) return widget.hint;
    final item = widget.items.firstWhere(
      (item) => item.value == _selectedValue,
      orElse: () =>
          DropdownCustomItem<T>(value: _selectedValue as T, label: widget.hint),
    );
    return item.label;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _createOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    // Trigger callback if no items found
    if (_filteredItems.isEmpty && _searchQuery.isNotEmpty) {
      widget.onNoItemsFound?.call();
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 8),
          child: Material(
            elevation: 4.0,
            borderRadius: _mainRadius,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                border: BoxBorder.all(
                  width: 1.5,
                  color: AppColors.gray400,
                ),
                borderRadius: _mainRadius,
              ),
              child: _filteredItems.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AppText(
                        'No items found',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = item.value == _selectedValue;
                        return InkWell(
                          onTap: item.selectable
                              ? () => _selectItem(item.value)
                              : null,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: AppDims.size_12,
                              horizontal: AppDims.size_12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.ci3
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            margin: EdgeInsets.all(8),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (item.leadingIcon != null) ...[
                                  item.leadingIcon!,
                                  AppDims.horizonPadding_8,
                                ],
                                Expanded(
                                  child:
                                      item.labelWidget ??
                                      AppText(
                                        item.label,
                                        textAlign: TextAlign.start,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: AppColors.gray600,
                                            ),
                                      ),
                                ),
                                if (item.trailingIcon != null) ...[
                                  AppDims.horizonPadding_8,
                                  item.trailingIcon!,
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _autoSelectFirstItem() {
    if (_filteredItems.isNotEmpty && _filteredItems.first.selectable) {
      _selectItem(_filteredItems.first.value);
    }
  }

  void _toggleDropdown() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        // _focusNode.requestFocus();
        _createOverlay();
      } else {
        _focusNode.unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
        _removeOverlay();
        // เคลียร์ Text Filter เมื่อปิด dropdown
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  void _selectItem(T item) {
    setState(() {
      _selectedValue = item;
      _isOpen = false;
      _searchQuery = '';
      _searchController.clear();
    });
    _focusNode.unfocus();
    _removeOverlay();
    widget.onChanged?.call(item);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                enabled: widget.isInteractive,
                readOnly: !widget.isInteractive,
                textAlign: TextAlign.start,
                style: AppTextStyles.labelLarge,
                decoration: InputDecoration(
                  hintText: _selectedLabel,
                  hintStyle: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.gray600,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  filled: true,
                  fillColor: widget.showDisableDecoration
                      ? AppColors.bareBackground
                      : AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: _mainRadius,
                    borderSide: BorderSide(
                      width: 1.5.w,
                      color: AppColors.gray400,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: _mainRadius,
                    borderSide: BorderSide(
                      width: 1.5.w,
                      color: AppColors.gray400,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: _mainRadius,
                    borderSide: BorderSide(
                      width: 1.5,
                      color: AppColors.gray400,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.gray500,
                    ),
                    onPressed: widget.isInteractive ? _toggleDropdown : null,
                  ),
                ),
                onChanged: widget.isInteractive
                    ? (value) {
                        setState(() {
                          _searchQuery = value;
                          if (!_isOpen && value.isNotEmpty) {
                            _isOpen = true;
                            _createOverlay();
                          } else if (_isOpen) {
                            _removeOverlay();
                            _createOverlay();
                          }
                        });
                      }
                    : null,
                onTap: widget.isInteractive
                    ? () {
                        if (!_isOpen) {
                          setState(() {
                            _isOpen = true;
                            _createOverlay();
                          });
                        }
                      }
                    : null,
                onSubmitted: widget.isInteractive
                    ? (value) {
                        // Auto select item แรกเมื่อกด Done บน keyboard (ถ้ามี filtered items)
                        if (_searchQuery.isNotEmpty &&
                            _filteredItems.isNotEmpty) {
                          _autoSelectFirstItem();
                        } else {
                          // ถ้าไม่มี filtered items หรือไม่ได้กรอกอะไร ให้ปิด dropdown
                          _toggleDropdown();
                        }
                      }
                    : null,
              ),
            ),
            AppDims.horizonPadding_4,
            // Container Icon
            Material(
              color: widget.showDisableDecoration
                  ? AppColors.bareBackground
                  : AppColors.white,
              borderRadius: _mainRadius,
              child: InkWell(
                onTap: widget.onLocationTap,
                borderRadius: _mainRadius,
                child: Container(
                  width: 40.w,
                  decoration: BoxDecoration(
                    border: BoxBorder.all(
                      width: 1.5.w,
                      color: AppColors.gray400,
                    ),
                    borderRadius: _mainRadius,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0.w),
                    child: Assets.svg.icLocation.svg(
                      colorFilter: ColorFilter.mode(
                        AppColors.gray500,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BorderRadius get _mainRadius => BorderRadius.circular(8.r);
}
