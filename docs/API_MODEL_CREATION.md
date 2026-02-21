# Creating API Endpoints and Response Models

This document describes the step-by-step process for creating API endpoints from cURL commands and building response models from JSON data in the Browny application.

---

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Step-by-Step Process](#step-by-step-process)
4. [JSON Structure Patterns](#json-structure-patterns)
5. [Model Patterns](#model-patterns)
6. [Helper Methods](#helper-methods)
7. [Code Generation](#code-generation)
8. [Examples](#examples)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

---

## Overview

### Workflow Diagram

```
┌─────────────────┐
│  cURL Command   │
│  + JSON Sample  │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  1. Analyze JSON Structure          │
│     - Identify field types          │
│     - Find multi-language fields    │
│     - Find reusable models          │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  2. Create Response Model           │
│     - @JsonSerializable()           │
│     - @JsonKey annotations          │
│     - ContentLocalizeData fields    │
│     - Nested models                 │
│     - Helper methods                │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  3. Add API Endpoint                │
│     - app_client.dart               │
│     - Retrofit annotations          │
│     - Documentation                 │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  4. Export Model                    │
│     - api_model_index.dart          │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  5. Run Code Generation             │
│     - build_runner                  │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  6. Verify Compilation              │
│     - Check errors                  │
│     - Test with sample JSON         │
└─────────────────────────────────────┘
```

---

## Prerequisites

### Required Knowledge
- Dart/Flutter basics
- JSON structure
- HTTP methods (GET, POST, etc.)
- Basic understanding of Retrofit

### Tools Required
- Dart SDK
- build_runner package
- json_annotation package
- retrofit package

### Existing Utilities
- **`ContentLocalizeData`**: For multi-language fields (th/en/zh)
- **`PaymentMethodsData`**: For payment method flags
- **Base Response Classes**: `BaseModelResponse`, `BaseResponse`
- **Code Generation**: `build_runner`

---

## Step-by-Step Process

### Step 1: Analyze the cURL Command

**Example cURL:**
```bash
curl --location 'https://dev.abgroup.co.th/api/machines/21' \
--header 'Accept: application/json'
```

**Extract Information:**
- **Method**: GET
- **Endpoint**: `/machines/{id}`
- **Path Parameters**: `id` (machine ID)
- **Query Parameters**: None
- **Body**: None
- **Headers**: Accept: application/json

---

### Step 2: Analyze the JSON Response

**Example JSON:**
```json
{
    "id": 21,
    "store_name": {
        "th": "ตลาดคูล - บางกรวย",
        "en": "Cool Market - Bang Kruai",
        "zh": "-"
    },
    "status": "Busy",
    "finish_datatime": "",
    "remaining_time": "00:00:00",
    "machine_no": "4",
    "name": {
        "th": "เครื่องอบ 4 - 16.00 กก.",
        "en": "Dryer 4 - 16.00 kg",
        "zh": "烘干机 4 - 16.00 公斤"
    }
}
```

**Identify Patterns:**

1. **Multi-language fields** (use `ContentLocalizeData`):
   - `store_name` → object with th/en/zh
   - `name` → object with th/en/zh

2. **Simple fields** (use standard Dart types):
   - `id` → `int`
   - `status` → `String`
   - `finish_datatime` → `String`
   - `remaining_time` → `String`
   - `machine_no` → `String`

3. **Response Structure**:
   - Is it wrapped in a `data` object? **NO** (direct object)
   - Does it have `success`, `message`, `error_type`? **NO**

---

### Step 3: Create Response Model

#### 3.1 Create the File

**Location:**
```
lib/core/data/remote/models/response/machine_detail_response.dart
```

#### 3.2 Write the Model

```dart
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'machine_detail_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class MachineDetailResponse extends BaseModelResponse {
  MachineDetailResponse({
    this.id,
    this.storeName,
    this.status,
    this.finishDatatime,
    this.remainingTime,
    this.machineNo,
    this.name,
    super.success,
    super.message,
    super.errorType,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'store_name')
  final ContentLocalizeData? storeName;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'finish_datatime')
  final String? finishDatatime;

  @JsonKey(name: 'remaining_time')
  final String? remainingTime;

  @JsonKey(name: 'machine_no')
  final String? machineNo;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  /// ดึงชื่อร้านตาม locale
  String getStoreNameDisplay(String locale) {
    return storeName?.getByLocaleCode(locale) ?? '';
  }

  /// ดึงชื่อเครื่องตาม locale
  String getMachineNameDisplay(String locale) {
    return name?.getByLocaleCode(locale) ?? '';
  }

  /// เช็คว่าเครื่องว่างหรือไม่
  bool get isAvailable => status?.toLowerCase() == 'available';

  /// เช็คว่าเครื่องกำลังทำงานหรือไม่
  bool get isBusy => status?.toLowerCase() == 'busy';

  factory MachineDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$MachineDetailResponseFromJson(json);
  
  Map<String, dynamic> toJson() =>
      baseToJson(_$MachineDetailResponseToJson(this));
}
```

**Key Points:**
- ✅ `@JsonSerializable()` annotation on class
- ✅ `@JsonKey(name: 'json_field_name')` for snake_case → camelCase mapping
- ✅ Use `ContentLocalizeData` for multi-language fields
- ✅ All fields nullable (`Type?`)
- ✅ Helper methods for locale-specific display
- ✅ Business logic getters (`isAvailable`, `isBusy`)
- ✅ `part` directive pointing to generated file
- ✅ `fromJson` and `toJson` factory methods

---

### Step 4: Add API Endpoint to AppClient

**File:** `lib/core/data/remote/app_client.dart`

```dart
/// DONG 2026-02-20
///
/// API fetch รายละเอียดเครื่อง (machine detail)
///
/// Response:
/// - MachineDetailResponse with machine info, status, remaining time
@GET('/machines/{id}')
Future<HttpResponse<MachineDetailResponse>> fetchMachineDetail(
  @Path('id') String machineId,
);
```

**Documentation Format:**
```dart
/// DONG YYYY-MM-DD
///
/// [Thai description of what the API does]
///
/// [Optional: Parameters section]
/// - parameter1: description
/// - parameter2: description
///
/// [Optional: Response section]
/// - ResponseType with description
@HTTP_METHOD('/endpoint/{path}')
Future<HttpResponse<ResponseType>> methodName(
  @Path('path') Type pathParam,
  @Query('query') Type queryParam,
  @Body() Type bodyParam,
);
```

---

### Step 5: Export Model

**File:** `lib/core/data/remote/models/api_model_index.dart`

Add the export statement in alphabetical order:

```dart
export 'package:browny_applications_new/core/data/remote/models/response/machine_detail_response.dart';
```

---

### Step 6: Run Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Expected Output:**
```
[INFO] Generating build script completed, took 420ms
[INFO] Creating build script snapshot... completed, took 10.1s
[INFO] Building new asset graph completed, took 821ms
[INFO] Checking for unexpected pre-existing outputs completed, took 1ms
[INFO] Running build completed, took 23s
[INFO] Caching finalized dependency graph completed, took 34ms
[SUCCESS] Succeeded after 23s with 8 outputs
```

**Generated Files:**
- `machine_detail_response.g.dart` - JSON serialization code
- `app_client.g.dart` - Retrofit implementation (updated)

---

### Step 7: Verify Compilation

Check for errors:
```bash
# In terminal or use IDE
flutter analyze
```

**Common Issues:**
- Missing imports
- Incorrect field types
- Wrong BaseResponse inheritance
- Missing required super parameters

---

## JSON Structure Patterns

### Pattern 1: Direct Response (No Wrapper)

**JSON:**
```json
{
  "id": 21,
  "name": "Machine 1",
  "status": "Available"
}
```

**Model:**
```dart
@JsonSerializable()
class MachineResponse {
  MachineResponse({
    this.id,
    this.name,
    this.status,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'status')
  final String? status;

  factory MachineResponse.fromJson(Map<String, dynamic> json) =>
      _$MachineResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$MachineResponseToJson(this);
}
```

---

### Pattern 2: Response with BaseModelResponse Wrapper

**JSON:**
```json
{
  "success": true,
  "message": "Success",
  "error_type": "",
  "data": {
    "id": 21,
    "name": "Machine 1"
  }
}
```

**Model:**
```dart
@JsonSerializable()
class MachineResponse extends BaseModelResponse {
  MachineResponse({
    required super.message,
    required super.errorType,
    super.success,
    this.data,
  });

  @JsonKey(name: 'data')
  final MachineData? data;

  factory MachineResponse.fromJson(Map<String, dynamic> json) =>
      _$MachineResponseFromJson(json);
  
  Map<String, dynamic> toJson() =>
      baseToJson(_$MachineResponseToJson(this));
}

@JsonSerializable()
class MachineData {
  MachineData({
    this.id,
    this.name,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  factory MachineData.fromJson(Map<String, dynamic> json) =>
      _$MachineDataFromJson(json);
  
  Map<String, dynamic> toJson() => _$MachineDataToJson(this);
}
```

---

### Pattern 3: Multi-Language Fields

**JSON:**
```json
{
  "name": {
    "th": "เครื่องซัก",
    "en": "Washer",
    "zh": "洗衣机"
  }
}
```

**Model:**
```dart
@JsonSerializable()
class MachineResponse {
  MachineResponse({
    this.name,
  });

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  /// ดึงชื่อเครื่องตาม locale
  String getNameDisplay(String locale) {
    return name?.getByLocaleCode(locale) ?? '';
  }

  factory MachineResponse.fromJson(Map<String, dynamic> json) =>
      _$MachineResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$MachineResponseToJson(this);
}
```

**Usage:**
```dart
final locale = Localizations.localeOf(context).languageCode;
final displayName = response.getNameDisplay(locale);
// locale = 'th' → "เครื่องซัก"
// locale = 'en' → "Washer"
// locale = 'zh' → "洗衣机"
```

---

### Pattern 4: Nested Objects

**JSON:**
```json
{
  "program": {
    "id": 1,
    "name": "Cold Water",
    "discount": {
      "id": 10,
      "name": "Rainy Discount",
      "value": 20
    }
  }
}
```

**Model:**
```dart
@JsonSerializable()
class ProgramResponse {
  ProgramResponse({
    this.program,
  });

  @JsonKey(name: 'program')
  final ProgramData? program;

  factory ProgramResponse.fromJson(Map<String, dynamic> json) =>
      _$ProgramResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$ProgramResponseToJson(this);
}

@JsonSerializable()
class ProgramData {
  ProgramData({
    this.id,
    this.name,
    this.discount,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'discount')
  final DiscountData? discount;

  factory ProgramData.fromJson(Map<String, dynamic> json) =>
      _$ProgramDataFromJson(json);
  
  Map<String, dynamic> toJson() => _$ProgramDataToJson(this);
}

@JsonSerializable()
class DiscountData {
  DiscountData({
    this.id,
    this.name,
    this.value,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'value')
  final int? value;

  factory DiscountData.fromJson(Map<String, dynamic> json) =>
      _$DiscountDataFromJson(json);
  
  Map<String, dynamic> toJson() => _$DiscountDataToJson(this);
}
```

---

### Pattern 5: Lists/Arrays

**JSON:**
```json
{
  "programs": [
    {
      "id": 1,
      "name": "Cold Water"
    },
    {
      "id": 2,
      "name": "Hot Water"
    }
  ]
}
```

**Model:**
```dart
@JsonSerializable()
class ProgramsResponse {
  ProgramsResponse({
    this.programs,
  });

  @JsonKey(name: 'programs')
  final List<ProgramData>? programs;

  factory ProgramsResponse.fromJson(Map<String, dynamic> json) =>
      _$ProgramsResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$ProgramsResponseToJson(this);
}

@JsonSerializable()
class ProgramData {
  ProgramData({
    this.id,
    this.name,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  factory ProgramData.fromJson(Map<String, dynamic> json) =>
      _$ProgramDataFromJson(json);
  
  Map<String, dynamic> toJson() => _$ProgramDataToJson(this);
}
```

---

### Pattern 6: Reusing Existing Models

**JSON:**
```json
{
  "payment_methods": {
    "qr": true,
    "credit_card": false,
    "true_money": true,
    "shopee_pay": true,
    "wechat": true,
    "rabbit_line": true,
    "tp_wallet": true
  }
}
```

**Model:**
```dart
// Import existing model
import 'package:browny_applications_new/core/data/remote/models/response/coupon_detail_response.dart';

@JsonSerializable()
class PaymentResponse {
  PaymentResponse({
    this.paymentMethods,
  });

  @JsonKey(name: 'payment_methods')
  final PaymentMethodsData? paymentMethods;  // Reuse existing class!

  factory PaymentResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$PaymentResponseToJson(this);
}
```

**Benefits:**
- ✅ No code duplication
- ✅ Consistent field names
- ✅ Shared business logic
- ✅ Easier maintenance

---

## Model Patterns

### snake_case → camelCase Mapping

**JSON Field:** `store_name`  
**Dart Field:** `storeName`  
**Annotation:** `@JsonKey(name: 'store_name')`

```dart
@JsonKey(name: 'store_name')
final String? storeName;
```

### Nullable vs Non-Nullable

**Default: All fields nullable**
```dart
final String? name;  // Can be null
final int? id;       // Can be null
```

**When to use non-nullable:**
- Fields guaranteed by API contract
- Required by business logic

```dart
final String name;   // Never null (rarely used)
```

### Field Types Mapping

| JSON Type | Dart Type | Example |
|-----------|-----------|---------|
| string | `String?` | `"Hello"` |
| number (integer) | `int?` | `123` |
| number (decimal) | `double?` | `123.45` |
| boolean | `bool?` | `true/false` |
| object | `CustomClass?` or `Map<String, dynamic>?` | `{"key": "value"}` |
| array | `List<Type>?` | `[1, 2, 3]` |
| null | Any nullable type | `null` |

### ContentLocalizeData Usage

**When to use:**
- Field contains `th`, `en`, `zh` keys
- Content needs to be displayed in multiple languages

**Example:**
```dart
// JSON
{
  "name": {
    "th": "ข้อความภาษาไทย",
    "en": "English text",
    "zh": "中文文本"
  }
}

// Dart
@JsonKey(name: 'name')
final ContentLocalizeData? name;

// Helper method
String getNameDisplay(String locale) {
  return name?.getByLocaleCode(locale) ?? '';
}
```

---

## Helper Methods

### Pattern 1: Locale-Specific Display

```dart
/// ดึง[FieldName]ตาม locale
String get[FieldName]Display(String locale) {
  return [field]?.getByLocaleCode(locale) ?? '';
}
```

**Example:**
```dart
/// ดึงชื่อร้านตาม locale
String getStoreNameDisplay(String locale) {
  return storeName?.getByLocaleCode(locale) ?? '';
}
```

### Pattern 2: Status Checks

```dart
/// เช็คว่า[condition description]
bool get is[StatusName] => [field]?.toLowerCase() == '[status_value]';
```

**Example:**
```dart
/// เช็คว่าเครื่องว่างหรือไม่
bool get isAvailable => status?.toLowerCase() == 'available';

/// เช็คว่าเครื่องกำลังทำงานหรือไม่
bool get isBusy => status?.toLowerCase() == 'busy';
```

### Pattern 3: Type Checks

```dart
/// เช็คว่าเป็น[type description]หรือไม่
bool get is[TypeName] => [field]?.toLowerCase() == '[type_value]';
```

**Example:**
```dart
/// เช็คว่าเป็นส่วนลดแบบ percent หรือไม่
bool get isPercentDiscount => type?.toLowerCase() == 'percent';

/// เช็คว่าเป็นส่วนลดแบบ fixed amount หรือไม่
bool get isFixedDiscount => type?.toLowerCase() == 'fixed';
```

### Pattern 4: Nullable Checks

```dart
/// เช็คว่ามี[field description]หรือไม่
bool get has[FieldName] => [field] != null;
```

**Example:**
```dart
/// เช็คว่ามีส่วนลดหรือไม่
bool get hasDiscount => discount != null;

/// เช็คว่ามีรูปภาพหรือไม่
bool get hasImage => image != null && image!.isNotEmpty;
```

### Pattern 5: Complex Business Logic

```dart
/// เช็คว่า[complex condition description]
bool get is[ConditionName] {
  if ([nullCheck] == null) return false;
  final [variable] = [calculation];
  return [condition];
}
```

**Example:**
```dart
/// เช็คว่าคูปองใกล้หมดอายุหรือไม่ (น้อยกว่า 7 วัน)
bool get isExpiringSoon {
  if (daysLeft == null) return false;
  final days = int.tryParse(daysLeft!) ?? 0;
  return days > 0 && days <= 7;
}
```

---

## Code Generation

### Command

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Flags Explained

- **`build`**: Generate code
- **`--delete-conflicting-outputs`**: Automatically delete old generated files that conflict

### Alternative Commands

```bash
# Watch mode (auto-regenerate on save)
dart run build_runner watch --delete-conflicting-outputs

# Clean generated files
dart run build_runner clean

# Build with verbose output
dart run build_runner build --verbose
```

### What Gets Generated?

1. **`*.g.dart` files** - JSON serialization code
2. **`app_client.g.dart`** - Retrofit implementation

**Example Generated Code:**
```dart
// machine_detail_response.g.dart

MachineDetailResponse _$MachineDetailResponseFromJson(
    Map<String, dynamic> json) =>
    MachineDetailResponse(
      id: json['id'] as int?,
      storeName: json['store_name'] == null
          ? null
          : ContentLocalizeData.fromJson(
              json['store_name'] as Map<String, dynamic>),
      status: json['status'] as String?,
      // ... more fields
    );

Map<String, dynamic> _$MachineDetailResponseToJson(
        MachineDetailResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'store_name': instance.storeName,
      'status': instance.status,
      // ... more fields
    };
```

---

## Examples

### Example 1: Simple Response (Machine Detail)

**cURL:**
```bash
curl --location 'https://dev.abgroup.co.th/api/machines/21' \
--header 'Accept: application/json'
```

**JSON Response:**
```json
{
    "id": 21,
    "store_name": {
        "th": "ตลาดคูล - บางกรวย",
        "en": "Cool Market - Bang Kruai",
        "zh": "-"
    },
    "status": "Busy",
    "finish_datatime": "",
    "remaining_time": "00:00:00",
    "machine_no": "4",
    "name": {
        "th": "เครื่องอบ 4 - 16.00 กก.",
        "en": "Dryer 4 - 16.00 kg",
        "zh": "烘干机 4 - 16.00 公斤"
    }
}
```

**Implementation:**

**1. Create Model:**
```dart
// lib/core/data/remote/models/response/machine_detail_response.dart

import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'machine_detail_response.g.dart';

@JsonSerializable()
class MachineDetailResponse extends BaseModelResponse {
  MachineDetailResponse({
    this.id,
    this.storeName,
    this.status,
    this.finishDatatime,
    this.remainingTime,
    this.machineNo,
    this.name,
    super.success,
    super.message,
    super.errorType,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'store_name')
  final ContentLocalizeData? storeName;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'finish_datatime')
  final String? finishDatatime;

  @JsonKey(name: 'remaining_time')
  final String? remainingTime;

  @JsonKey(name: 'machine_no')
  final String? machineNo;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  /// ดึงชื่อร้านตาม locale
  String getStoreNameDisplay(String locale) {
    return storeName?.getByLocaleCode(locale) ?? '';
  }

  /// ดึงชื่อเครื่องตาม locale
  String getMachineNameDisplay(String locale) {
    return name?.getByLocaleCode(locale) ?? '';
  }

  /// เช็คว่าเครื่องว่างหรือไม่
  bool get isAvailable => status?.toLowerCase() == 'available';

  /// เช็คว่าเครื่องกำลังทำงานหรือไม่
  bool get isBusy => status?.toLowerCase() == 'busy';

  factory MachineDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$MachineDetailResponseFromJson(json);
  
  Map<String, dynamic> toJson() =>
      baseToJson(_$MachineDetailResponseToJson(this));
}
```

**2. Add API Endpoint:**
```dart
// lib/core/data/remote/app_client.dart

/// DONG 2026-02-20
///
/// API fetch รายละเอียดเครื่อง (machine detail)
///
/// Response:
/// - MachineDetailResponse with machine info, status, remaining time
@GET('/machines/{id}')
Future<HttpResponse<MachineDetailResponse>> fetchMachineDetail(
  @Path('id') String machineId,
);
```

**3. Export Model:**
```dart
// lib/core/data/remote/models/api_model_index.dart

export 'package:browny_applications_new/core/data/remote/models/response/machine_detail_response.dart';
```

**4. Run build_runner:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

### Example 2: Complex Nested Response (Machine Programs)

**cURL:**
```bash
curl --location 'https://dev.abgroup.co.th/api/machine/5/programs?customer_id={uuid}' \
--header 'Accept: application/json'
```

**JSON Response (Simplified):**
```json
{
    "machine_id": 5,
    "machine_name": {
        "th": "เครื่องซัก 1",
        "en": "Washer 1",
        "zh": "洗衣机 1"
    },
    "programs": [
        {
            "id": 2295,
            "name": {
                "th": "น้ำเย็น",
                "en": "Cold Water",
                "zh": "冷水"
            },
            "price": "50.00",
            "discount": {
                "id": 22,
                "name": {
                    "th": "ส่วนลดหน้าฝน",
                    "en": "Rainy Discount",
                    "zh": "雨季优惠"
                },
                "type": "percent",
                "value": 20
            }
        }
    ],
    "payment_methods": {
        "qr": true,
        "credit_card": false,
        "true_money": true
    }
}
```

**Implementation:**

**1. Create Nested Models:**
```dart
// lib/core/data/remote/models/response/machine_programs_response.dart

import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coupon_detail_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'machine_programs_response.g.dart';

// Main Response
@JsonSerializable()
class MachineProgramsResponse {
  MachineProgramsResponse({
    this.machineId,
    this.machineName,
    this.programs,
    this.paymentMethods,
  });

  @JsonKey(name: 'machine_id')
  final int? machineId;

  @JsonKey(name: 'machine_name')
  final ContentLocalizeData? machineName;

  @JsonKey(name: 'programs')
  final List<ProgramData>? programs;

  @JsonKey(name: 'payment_methods')
  final PaymentMethodsData? paymentMethods;  // Reuse existing model!

  /// ดึงชื่อเครื่องตาม locale
  String getMachineNameDisplay(String locale) {
    return machineName?.getByLocaleCode(locale) ?? '';
  }

  factory MachineProgramsResponse.fromJson(Map<String, dynamic> json) =>
      _$MachineProgramsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MachineProgramsResponseToJson(this);
}

// Nested: Program Data
@JsonSerializable()
class ProgramData {
  ProgramData({
    this.id,
    this.name,
    this.price,
    this.discount,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  @JsonKey(name: 'price')
  final String? price;

  @JsonKey(name: 'discount')
  final DiscountData? discount;

  /// ดึงชื่อโปรแกรมตาม locale
  String getProgramNameDisplay(String locale) {
    return name?.getByLocaleCode(locale) ?? '';
  }

  /// เช็คว่ามีส่วนลดหรือไม่
  bool get hasDiscount => discount != null;

  factory ProgramData.fromJson(Map<String, dynamic> json) =>
      _$ProgramDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProgramDataToJson(this);
}

// Nested: Discount Data
@JsonSerializable()
class DiscountData {
  DiscountData({
    this.id,
    this.name,
    this.type,
    this.value,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'value')
  final int? value;

  /// ดึงชื่อส่วนลดตาม locale
  String getDiscountNameDisplay(String locale) {
    return name?.getByLocaleCode(locale) ?? '';
  }

  /// เช็คว่าเป็นส่วนลดแบบ percent หรือไม่
  bool get isPercentDiscount => type?.toLowerCase() == 'percent';

  factory DiscountData.fromJson(Map<String, dynamic> json) =>
      _$DiscountDataFromJson(json);

  Map<String, dynamic> toJson() => _$DiscountDataToJson(this);
}
```

**2. Add API Endpoint:**
```dart
// lib/core/data/remote/app_client.dart

/// DONG 2026-02-20
///
/// API fetch โปรแกรมของเครื่อง (machine programs)
///
/// Query parameters:
/// - customer_id: String (uuid)
///
/// Response:
/// - MachineProgramsResponse with programs, available coupons, payment methods
@GET('/machine/{id}/programs')
Future<HttpResponse<MachineProgramsResponse>> fetchMachinePrograms(
  @Path('id') String machineId,
  @Query('customer_id') String customerId,
);
```

**3. Export Model:**
```dart
// lib/core/data/remote/models/api_model_index.dart

export 'package:browny_applications_new/core/data/remote/models/response/machine_programs_response.dart';
```

**4. Run build_runner:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Best Practices

### 1. Model Design

✅ **DO:**
- Use `ContentLocalizeData` for multi-language fields
- Reuse existing models when possible (e.g., `PaymentMethodsData`)
- Add helper methods for locale-specific display
- Add business logic getters for status checks
- Document helper methods with Thai comments
- Make all fields nullable unless guaranteed by API
- Use descriptive field names in camelCase

❌ **DON'T:**
- Don't hardcode locale values in model
- Don't duplicate existing model classes
- Don't put UI logic in models
- Don't use non-nullable fields without good reason
- Don't forget to add helper methods

### 2. Naming Conventions

**Class Names:**
- Response models: `[Feature]Response`
- Data classes: `[Feature]Data`
- Examples: `MachineDetailResponse`, `ProgramData`

**Field Names:**
- camelCase for Dart
- snake_case for JSON (with `@JsonKey`)

**Helper Methods:**
- `get[Field]Display(String locale)` - for locale-specific display
- `is[Status]` - for boolean status checks
- `has[Field]` - for nullable field checks

**Example:**
```dart
String getStoreNameDisplay(String locale) { ... }
bool get isAvailable { ... }
bool get hasDiscount { ... }
```

### 3. File Organization

```
lib/
└── core/
    └── data/
        └── remote/
            ├── app_client.dart              # API endpoints
            └── models/
                ├── api_model_index.dart     # Export all models
                ├── content_localize_data.dart
                └── response/
                    ├── machine_detail_response.dart
                    ├── machine_programs_response.dart
                    └── ...
```

### 4. Documentation

**API Endpoint Documentation:**
```dart
/// DONG YYYY-MM-DD
///
/// [Thai description]
///
/// [Optional sections for parameters, response, etc.]
```

**Helper Method Documentation:**
```dart
/// [Thai description of what the method does]
```

### 5. Error Prevention

**Before Running build_runner:**
- ✅ Check all imports
- ✅ Verify `part` directive is correct
- ✅ Ensure all `@JsonSerializable()` annotations present
- ✅ Verify `@JsonKey` annotations for snake_case fields
- ✅ Check factory methods are present

**Common Mistakes:**
```dart
// ❌ Wrong - missing part directive
@JsonSerializable()
class MyResponse { ... }

// ✅ Correct
part 'my_response.g.dart';

@JsonSerializable()
class MyResponse { ... }
```

```dart
// ❌ Wrong - no @JsonKey for snake_case
final ContentLocalizeData? store_name;

// ✅ Correct
@JsonKey(name: 'store_name')
final ContentLocalizeData? storeName;
```

### 6. Testing Models

**Test JSON Parsing:**
```dart
void main() {
  test('MachineDetailResponse.fromJson', () {
    final json = {
      'id': 21,
      'store_name': {
        'th': 'ร้านทดสอบ',
        'en': 'Test Store',
        'zh': '测试店'
      },
      'status': 'Available',
    };

    final response = MachineDetailResponse.fromJson(json);

    expect(response.id, 21);
    expect(response.getStoreNameDisplay('th'), 'ร้านทดสอบ');
    expect(response.isAvailable, true);
    expect(response.isBusy, false);
  });
}
```

---

## Troubleshooting

### Issue 1: Build Runner Fails

**Error:**
```
[SEVERE] json_serializable:json_serializable on lib/path/to/file.dart:
Could not generate `fromJson` code for `fieldName`.
```

**Solution:**
- Check that the field type is serializable
- For custom types, ensure they have `fromJson` factory
- For `ContentLocalizeData`, verify it's imported

---

### Issue 2: Missing Generated File

**Error:**
```
Error: Part not found: 'my_response.g.dart'
```

**Solution:**
1. Check `part` directive matches filename
2. Run build_runner: `dart run build_runner build --delete-conflicting-outputs`
3. Check for compilation errors in the source file

---

### Issue 3: Wrong JSON Field Mapping

**Error:**
```
type 'Null' is not a subtype of type 'String' in type cast
```

**Solution:**
- Verify `@JsonKey(name: 'json_field')` matches actual JSON
- Ensure field type matches JSON type (String vs int vs double)
- Make field nullable if it can be null in JSON

**Example:**
```dart
// JSON: "machine_no": "4"
@JsonKey(name: 'machine_no')
final String? machineNo;  // ✅ Correct

// JSON: "machine_id": 21
@JsonKey(name: 'machine_id')
final int? machineId;  // ✅ Correct
```

---

### Issue 4: BaseModelResponse Constructor Error

**Error:**
```
The parameter 'message' is required.
The parameter 'errorType' is required.
```

**Solution:**
Add `required super.message` and `required super.errorType`:

```dart
// ❌ Wrong
class MyResponse extends BaseModelResponse {
  MyResponse({
    super.message,
    super.errorType,
    super.success,
  });
}

// ✅ Correct
class MyResponse extends BaseModelResponse {
  MyResponse({
    required super.message,
    required super.errorType,
    super.success,
  });
}
```

---

### Issue 5: ContentLocalizeData Not Found

**Error:**
```
Undefined class 'ContentLocalizeData'
```

**Solution:**
Add import:
```dart
import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
```

---

## Quick Reference

### Model Template

```dart
import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'my_response.g.dart';

@JsonSerializable()
class MyResponse {
  MyResponse({
    this.id,
    this.name,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  /// ดึงชื่อตาม locale
  String getNameDisplay(String locale) {
    return name?.getByLocaleCode(locale) ?? '';
  }

  factory MyResponse.fromJson(Map<String, dynamic> json) =>
      _$MyResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$MyResponseToJson(this);
}
```

### API Endpoint Template

```dart
/// DONG YYYY-MM-DD
///
/// [Thai description]
@GET('/endpoint/{id}')
Future<HttpResponse<MyResponse>> fetchMyData(
  @Path('id') String id,
);
```

### Common Patterns Quick Reference

| Pattern | Use When | Example |
|---------|----------|---------|
| `ContentLocalizeData` | Multi-language field | `store_name: {th, en, zh}` |
| `List<Type>` | Array in JSON | `programs: [...]` |
| `NestedClass` | Object in JSON | `discount: {...}` |
| `ExistingClass` | Reusable structure | `PaymentMethodsData` |
| `BaseModelResponse` | Response has success/message/error_type | Wrapped responses |
| Direct class | No wrapper | Direct JSON object |

---

## Summary Checklist

When creating a new API and model:

1. ✅ Analyze cURL command (method, endpoint, parameters)
2. ✅ Analyze JSON response structure
3. ✅ Identify multi-language fields → use `ContentLocalizeData`
4. ✅ Identify reusable models → import and use existing classes
5. ✅ Create model file with proper naming
6. ✅ Add `@JsonSerializable()` annotation
7. ✅ Add `part` directive
8. ✅ Map all JSON fields with `@JsonKey`
9. ✅ Create nested models if needed
10. ✅ Add helper methods for display and business logic
11. ✅ Add `fromJson` and `toJson` factories
12. ✅ Add API endpoint to `app_client.dart`
13. ✅ Export model in `api_model_index.dart`
14. ✅ Run `dart run build_runner build --delete-conflicting-outputs`
15. ✅ Verify no compilation errors
16. ✅ Test with sample JSON data

---

## References

- **ContentLocalizeData**: `lib/core/data/remote/models/content_localize_data.dart`
- **PaymentMethodsData**: `lib/core/data/remote/models/response/coupon_detail_response.dart`
- **BaseModelResponse**: `lib/core/data/remote/models/response/base_response.dart`
- **AppClient**: `lib/core/data/remote/app_client.dart`
- **Example Models**: 
  - Simple: `machine_detail_response.dart`
  - Complex: `machine_programs_response.dart`

---

**Document Version:** 1.0  
**Last Updated:** 2026-02-20  
**Author:** Browny Development Team
