import 'dart:convert';

import 'package:browny_applications_new/core/data/remote/models/response/machine_detail_response.dart';
import 'package:flutter_test/flutter_test.dart';

/// Payload ตอนที่เครื่องยังไม่เริ่มทำงาน (จ่ายเงินแล้ว แต่ยังไม่กดปุ่มที่หน้าเครื่อง)
/// - status = Vacant, order_id / receipt_no ยังมีค่า
const notStartedJson = '''
{
  "id": 1385,
  "capacity_kg": 16,
  "store_name": {"th": "จรัญฯ 40", "en": "Charan 40", "zh": "-"},
  "status": "Vacant",
  "finish_datatime": "15:00",
  "remaining_time": "00:30:00",
  "machine_no": "2",
  "machine_type": {"th": "เครื่องซัก", "en": "Washer", "zh": "洗衣机"},
  "name": {"th": "เครื่องซัก 2", "en": "Washer 2", "zh": "洗衣机 2"},
  "order_id": "019fc165-dc19-701a-8b6f-f9abc49b6554",
  "receipt_no": "BNP20260802-143532803061",
  "startTime": "2026-08-02 14:30",
  "program_image": "https://example.com/program.png",
  "program_name": {"th": "น้ำเย็น", "en": "Cold", "zh": "冷水"}
}
''';

/// Payload ตอนที่เครื่องกำลังทำงาน
/// - status = Busy, order_id / receipt_no ยังมีค่า
const busyJson = '''
{
  "id": 1385,
  "capacity_kg": 16,
  "store_name": {"th": "จรัญฯ 40", "en": "Charan 40", "zh": "-"},
  "status": "Busy",
  "finish_datatime": "15:00",
  "remaining_time": "00:30:00",
  "machine_no": "2",
  "machine_type": {"th": "เครื่องซัก", "en": "Washer", "zh": "洗衣机"},
  "name": {"th": "เครื่องซัก 2", "en": "Washer 2", "zh": "洗衣机 2"},
  "order_id": "019fc165-dc19-701a-8b6f-f9abc49b6554",
  "receipt_no": "BNP20260802-143532803061",
  "startTime": "2026-08-02 14:30",
  "program_image": "https://example.com/program.png",
  "program_name": {"th": "น้ำเย็น", "en": "Cold", "zh": "冷水"}
}
''';

/// Payload ตอนที่เครื่องทำงานเสร็จแล้ว
/// - status กลับมาเป็น Vacant และ API เคลียร์ข้อมูล order ทิ้งทั้งหมด
const completedJson = '''
{
  "id": 1385,
  "capacity_kg": 16,
  "store_name": {"th": "จรัญฯ 40", "en": "Charan 40", "zh": "-"},
  "status": "Vacant",
  "finish_datatime": "",
  "remaining_time": "00:00:00",
  "machine_no": "2",
  "machine_type": {"th": "เครื่องซัก", "en": "Washer", "zh": "洗衣机"},
  "name": {"th": "เครื่องซัก 2", "en": "Washer 2", "zh": "洗衣机 2"},
  "order_id": "",
  "receipt_no": "",
  "startTime": "",
  "addTime": [],
  "program_image": "",
  "program_name": {"th": "", "en": "", "zh": ""}
}
''';

MachineDetailResponse parse(String json) =>
    MachineDetailResponse.fromJson(jsonDecode(json));

void main() {
  group('MachineDetailResponse - แยกสถานะเครื่อง', () {
    test('Vacant + มี order_id/receipt_no => ยังไม่เริ่มทำงาน', () {
      final machine = parse(notStartedJson);

      expect(machine.hasOrder, isTrue);
      expect(machine.isNotStarted, isTrue);
      expect(machine.isCompleted, isFalse);
    });

    test('Busy + มี order_id/receipt_no => กำลังทำงาน', () {
      final machine = parse(busyJson);

      expect(machine.hasOrder, isTrue);
      expect(machine.isNotStarted, isFalse);
      expect(machine.isCompleted, isFalse);
    });

    test('Vacant + order_id/receipt_no ว่าง => ทำงานเสร็จแล้ว', () {
      final machine = parse(completedJson);

      expect(machine.hasOrder, isFalse);
      expect(machine.isNotStarted, isFalse);
      expect(machine.isCompleted, isTrue);
      // สถานะที่แสดงต้องเป็น "สำเร็จ"
      expect(machine.getStatusDisplay('th'), 'สำเร็จ');
    });

    test('สถานะขัดข้อง (timeout/maintenance) ยังถือว่าไม่ได้เริ่มทำงาน', () {
      for (final status in ['timeout', 'maintenance', 'inactive']) {
        final machine = parse(
          notStartedJson.replaceFirst('"status": "Vacant"', '"status": "$status"'),
        );

        expect(machine.isCompleted, isFalse, reason: status);
        expect(machine.isNotStarted, isTrue, reason: status);
      }
    });
  });

  group('MachineDetailResponse.retainDataFrom - คงข้อมูล order เดิมไว้', () {
    test('เติมค่าที่ API เคลียร์ทิ้ง จาก response ก่อนหน้า', () {
      final previous = parse(busyJson);
      final completed = parse(completedJson).retainDataFrom(previous);

      // ข้อมูล order เดิมต้องยังอยู่
      expect(completed.receiptNo, 'BNP20260802-143532803061');
      expect(completed.orderId, '019fc165-dc19-701a-8b6f-f9abc49b6554');
      expect(completed.getProgramNameDisplay('th'), 'น้ำเย็น');
      expect(completed.programImage, 'https://example.com/program.png');
      expect(completed.startTime, DateTime(2026, 8, 2, 14, 30));
      expect(completed.finishDatatime, '15:00');
      expect(completed.getStoreNameDisplay('th'), 'จรัญฯ 40');

      // สถานะ + เวลาที่เหลือ ต้องใช้ค่าใหม่เสมอ
      expect(completed.status, 'Vacant');
      expect(completed.remainingTime, '00:00:00');
      expect(completed.getStatusDisplay('th'), 'สำเร็จ');

      // ยังต้องถือว่าเครื่องทำงานเสร็จแล้ว (เช็คจาก status + remaining_time)
      expect(completed.isCompleted, isTrue);
      expect(completed.isNotStarted, isFalse);
    });

    test('ค่าที่ API ส่งมาใหม่ต้องทับค่าเดิมเสมอ', () {
      final previous = parse(busyJson);
      final next = parse(
        notStartedJson
            .replaceFirst('"receipt_no": "BNP20260802-143532803061"', '"receipt_no": "BNP-NEW"')
            .replaceFirst('"th": "น้ำเย็น"', '"th": "น้ำร้อน"'),
      ).retainDataFrom(previous);

      expect(next.receiptNo, 'BNP-NEW');
      expect(next.getProgramNameDisplay('th'), 'น้ำร้อน');
    });

    test('ไม่มี response ก่อนหน้า ต้องคืนค่าเดิมโดยไม่พัง', () {
      final completed = parse(completedJson).retainDataFrom(null);

      expect(completed.isCompleted, isTrue);
      expect(completed.receiptNo, isEmpty);
    });
  });
}
