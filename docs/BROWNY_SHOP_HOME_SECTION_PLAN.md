# Browny Shop — Home Section Plan

แผนแบ่งย่อย Section "Browny Shop" ที่จะเพิ่มในหน้า [home_page.dart](../lib/feature/home/screens/home_page.dart)

อ้างอิง design: [design/browny_shop_home.css](../design/browny_shop_home.css)

---

## ภาพรวม Section (top → bottom)

```
┌─────────────────────────────────────────┐
│ [1] Top Banner Area         (placeholder) │
├─────────────────────────────────────────┤
│ [2] Header Row                            │
│  ic_browny_shop ────────── ic_bag (39×39) │
├─────────────────────────────────────────┤
│ [3] Search Box (tap → SearchPage)         │
│  [🔍 กระเป๋า…........................]    │
├─────────────────────────────────────────┤
│ [4] Mid Banner Area         (placeholder) │
├─────────────────────────────────────────┤
│ [5] Categories                            │
│  หมวดหมู่                  ดูทั้งหมด >    │
│  [ทั้งหมด] [ยอดนิยม] [Browny Sale] [น้องบ│
├─────────────────────────────────────────┤
│ [6] Featured Section                      │
│  [Title]                  ดูทั้งหมด >    │
│  ┌──────────┐ ┌──────────┐                │
│  │ Product  │ │ Product  │                │
│  └──────────┘ └──────────┘                │
└─────────────────────────────────────────┘
```

หน่วย design: viewport 375px wide, padding outer 16px ทั้งสองข้าง → content 343px

---

## [1] Top Banner Placeholder

**ไว้สำหรับ banner future** (ยังไม่ทำ)

| Property | Value |
|---|---|
| Width | 343 (full inner) |
| Height | TBD — จะให้ design มาภายหลัง |
| Layout | reserve ที่ว่างหรือยังไม่ใส่ก็ได้ในรอบแรก |

**Implementation note**: รอบแรกใส่ `SizedBox.shrink()` หรือ comment "TODO: top banner" ไว้

---

## [2] Header Row — Browny Shop + Bag

`Frame 2087326863` — width 343, height 39, **row** flex (justify start)

```
┌──────────────────────────────────────────────────────┐
│ [ic_browny_shop image]                  [ic_bag 39×39] │
└──────────────────────────────────────────────────────┘
```

| Element | Spec |
|---|---|
| Outer | Row, width 343, height 39, padding 0, column-gap 8 |
| Browny Shop logo | `Assets.icShop.icBrownyShop` (image) — ชิดซ้าย, fit width auto |
| Bag wrapper | `Frame 2087326536` — 39×39, white bg, border-radius 26 (full circle), padding 9/9, ชิดขวา |
| Bag icon | `Assets.icShop.icBag` (24×24 inside circle) |
| Spacer | `Spacer()` ระหว่าง logo กับ bag |

**Tap on bag** → TBD (อาจเป็น Cart page ในอนาคต)

---

## [3] Search Box (Tap → Route to SearchPage)

**Frame 2087327207 ภายใน → Input field** (real one — `input-aaabc886a6b3`)

| Property | Value |
|---|---|
| Width | 343 |
| Height | 40 |
| Background | `#F9FAFB` |
| Border | 1px `#DFDFDF` (= `AppColors.productStroke`) |
| Border radius | 8 |
| Padding | 12 top/bottom, 16 left/right |
| Layout | Row gap 8 (icon → text) |
| Icon | search/magnifier 12×12 (CSS class `vector-246d2a02dace`) |
| Placeholder | "กระเป๋า" — รับเป็น hint text |

**Behavior**: ⚠️ NOT ใช้เป็น `TextField` จริง → ใช้ `GestureDetector` + Container เลียนแบบหน้าตา input
- Tap → `Navigator.push` → `BrownyShopSearchPage` (สร้างใหม่ ภายหลัง)

**Flutter spec**:
```dart
GestureDetector(
  onTap: () => goSearchPage(),
  child: Container(
    height: 40.h,
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    decoration: BoxDecoration(
      color: Color(0xFFF9FAFB),
      border: Border.all(color: AppColors.productStroke),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Row(
      children: [Icon(search, 12), SizedBox(8), AppText(hint, ...)],
    ),
  ),
)
```

---

## [4] Mid Banner Placeholder

**ไว้สำหรับ banner future** — ระหว่าง Search กับ Categories
รอบแรก: `SizedBox.shrink()` หรือ TODO

---

## [5] Categories Section

**Frame 2087326519** — chips row + label

### 5.1 Section Title Row

```
หมวดหมู่                              ดูทั้งหมด >
```

| Element | Spec |
|---|---|
| Title text "หมวดหมู่" | font Mitr w400, size TBD (~16sp), color textPrimary |
| Right link "ดูทั้งหมด" | tap action → CategoryPage (TBD) |

### 5.2 Chips Row

5 chips ตาม design:

| Chip | Label | State |
|---|---|---|
| Input #d9b66224b378 | ทั้งหมด | active (default) |
| Input #a92c491f26e2 | ยอดนิยม | inactive |
| Input #41133ddff8d6 | Browny Sale | inactive |
| Input #5464cd2c6550 | น้องบราวนี่ | inactive |
| Input … | งานบ้าน | inactive |

**Chip spec** (ทั้งหมด / inactive):
- bg `#2FBA3800` (transparent)
- border 1px `#CDCDCD` (= `AppColors.gray400`)
- border-radius 4
- padding 8/8 horizontal
- column-gap 17 (icon ↔ text หรือ text only ก็ได้)
- height auto (~24)
- text height 24

**Active chip**: น่าจะเป็น primary color border + bg `ci3` หรือ primary (รอ design ยืนยัน — เริ่มจากตัวเดียว state = active แบบ filled)

**Layout**: Horizontal scroll list — chips อาจมีจำนวนเพิ่มได้

**Behavior**: ใช้เป็น filter — state เก็บใน VM `selectedCategoryNotifier`

---

## [6] Featured / Product Grid Section

**Frame 2087326927** — title + grid

### 6.1 Section Title Row

```
[Title แสดงตาม category]              ดูทั้งหมด >
```

`Frame 2087326496` (title row, hidden in CSS = `display: none` แต่อยู่ใน DOM)
`Frame 2087326498` — flex row, gap 8

### 6.2 Grid 2-col

`Frame 2087326510` — column gap 16
`Frame 2087326509` — row, justify space-between (2 cards per row)

| Property | Value |
|---|---|
| Card width | 163 (= (343 - gap 16) / 2 ≈ 163.5) |
| Card spec | ตาม `ProductItemWidget` ที่สร้างไว้ |
| Spacing | 16 row gap, space-between (= ~16 column gap) |

**Implementation**: ใช้ `GridView.builder` หรือ `Column` of `Row` (2 ต่อแถว) ก็ได้

**Behavior**:
- Filter ตาม chip ที่เลือก
- Tap product → `BrownyShopProductDetailPage`
- Tap "ดูทั้งหมด" → `BrownyShopListPage` (filter ทั้งหมดของ category)

---

## Code Skeleton (Flutter)

ที่ [home_page.dart](../lib/feature/home/screens/home_page.dart) — เพิ่ม sliver ต่อจาก `_buildServices`:

```dart
SliverToBoxAdapter(
  child: _buildBrownyShopSection(context),
),
```

แล้วแยก method:

```dart
Widget _buildBrownyShopSection(BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // [1] _buildShopTopBanner()           // TODO future
        _buildShopHeaderRow(context),          // [2]
        AppDims.vericalPadding_16,
        _buildShopSearchBox(context),          // [3]
        AppDims.vericalPadding_24,
        // [4] _buildShopMidBanner()           // TODO future
        _buildShopCategoryTitle(context),      // [5.1]
        AppDims.vericalPadding_16,
        _buildShopCategoryChips(context),      // [5.2]
        AppDims.vericalPadding_16,
        _buildShopFeaturedTitle(context),      // [6.1]
        AppDims.vericalPadding_16,
        _buildShopFeaturedGrid(context),       // [6.2]
      ],
    ),
  );
}
```

---

## ตัวเลขจาก Design (Reference Only)

| ตัวแปร | Pixel | Token |
|---|---|---|
| Outer horizontal padding | 16 | `AppDims.size_16` |
| Header height | 39 | — |
| Bag circle size | 39 | — |
| Bag icon size | 24 | `AppDims.size_24` |
| Search box height | 40 | `AppDims.size_40` |
| Search border radius | 8 | — |
| Search bg | `#F9FAFB` | TBD or new const |
| Card width | 163 | calc dynamic |
| Card min-height | 240 | — |
| Card border | 1px `#DFDFDF` | `AppColors.productStroke` |
| Card radius | 16 | — |
| Chip border | 1px `#CDCDCD` | `AppColors.gray400` |
| Chip radius | 4 | — |
| Chip padding | 0/8 | — |

---

## State / Data ที่ต้องเตรียม (ภายหลัง)

ใน `HomePageViewmodel` (หรือ `BrownyShopHomeViewmodel` แยก):

```dart
// Categories
ValueNotifier<List<CategoryModel>> categoriesNotifier;
ValueNotifier<String?> selectedCategoryIdNotifier;

// Featured products
ValueNotifier<UiResult<List<ProductData>>> featuredProductsNotifier;

Future<void> fetchFeaturedProducts({String? categoryId});
Future<void> onCategorySelected(String id);
```

Repo: ใช้ `ProductsResponse` + `fetchProducts(productType, customerId)` ที่มีอยู่แล้ว

---

## หน้า Page ที่ต้องสร้างเพิ่ม (อนาคต)

| Page | จุดประสงค์ |
|---|---|
| `BrownyShopSearchPage` | กดที่ search box → ค้นหาสินค้า |
| `BrownyShopListPage` | ดูทั้งหมด (filter ตาม category) |
| `BrownyShopProductDetailPage` | กด product → ดูรายละเอียด (ใช้ `fetchProductDetail`) |
| `BrownyShopCartPage` | กด ic_bag → ตะกร้า |

---

## ลำดับการ Implement

1. ⭐ Skeleton ทุก sub-method (ไม่มี data จริง — ใช้ mock ก่อน)
2. Header row [2] + Search box [3] (UI only, tap log)
3. Category chips [5] (mock 5 categories, state local)
4. Featured grid [6] (ใช้ `ProductItemWidget` + mock data ที่ใช้ใน POC)
5. เชื่อม API จริง — `fetchProducts`
6. สร้าง pages ปลายทาง (Search, List, Detail) ทีละหน้า

---

**Last Updated**: 2026-05-10
