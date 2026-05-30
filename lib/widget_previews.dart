import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// **************************************************************************
// Widget Previews สำหรับ Browny Application
//
// วิธีเปิด:
//   flutter widget-preview start
//   (หรือ IDE จะเปิดให้อัตโนมัติบน Flutter 3.38+)
//
// วิธีเพิ่ม preview ใหม่:
//   1. สร้างฟังก์ชัน top-level / static method ที่คืนค่า Widget
//   2. ติด @Preview(name: 'ชื่อ', group: 'หมวด') ด้านบน
//   3. ถ้า widget ต้อง ScreenUtil ให้ครอบด้วย previewScreenUtil(...)
//
// อ้างอิง: https://docs.flutter.dev/tools/widget-previewer
// **************************************************************************

/// Wrapper ครอบ widget ให้พร้อมใช้ ScreenUtil ภายใน preview
/// (เพราะโปรเจคใช้ .w/.h/.sp ทั่วทั้งโปรเจค)
Widget previewScreenUtil(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    builder: (context, _) => child,
  );
}

@Preview(name: 'Hello — sanity check')
Widget helloPreview() {
  return const Center(
    child: Text(
      'Widget Previewer พร้อมใช้งาน ✅',
      style: TextStyle(fontSize: 18),
    ),
  );
}

@Preview(
  group: 'Brightness',
  name: 'Card — light',
  brightness: Brightness.light,
)
@Preview(
  group: 'Brightness',
  name: 'Card — dark',
  brightness: Brightness.dark,
)
Widget sampleCardPreview() {
  return previewScreenUtil(
    Builder(
      builder: (context) => Card(
        margin: EdgeInsets.all(16.w),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ตัวอย่างการ์ด', style: TextStyle(fontSize: 18.sp)),
              SizedBox(height: 8.h),
              Text(
                'การ์ดนี้ใช้ ScreenUtil .w/.h/.sp ปกติ',
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
