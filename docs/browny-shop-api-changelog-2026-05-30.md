# Browny Shop API — Changelog (เพิ่ม/แก้ไข)

**วันที่:** 30 พฤษภาคม 2026  
**Base URL:** `{APP_URL}/api`  
**Auth:** `Authorization: Bearer {TOKEN}` (middleware `CheckApiToken`)

---

## สรุปการเปลี่ยนแปลง

| สถานะ | Method | Endpoint |
|-------|--------|----------|
| เพิ่มใหม่ | `POST` | `/browny-shop/favorites` |
| เพิ่มใหม่ | `DELETE` | `/browny-shop/favorites/{product_id}` |
| แก้ไข | `GET` | `/browny-shop/cart/summary` |
| แก้ไข | `POST` | `/browny-shop/cart/summary` |
| เพิ่มใหม่ | `POST` | `/browny-shop/checkout/confirm` |
| แก้ไข | `POST` | `/browny-shop/checkout/{order_id}/confirm` |
| แก้ไข | `GET` | `/browny-shop/checkout/{order_id}` |
| ยกเลิก | `POST` | `/browny-shop/checkout/draft` |
| ยกเลิก | `PATCH` | `/browny-shop/checkout/{order_id}` |

---

## 1. Favorite Items (เพิ่มใหม่)

### 1.1 เพิ่มสินค้าโปรด

**`POST /browny-shop/favorites`**

Request body:

```json
{
  "customer_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "product_id": "f9e8d7c6-b5a4-3210-fedc-ba0987654321"
}
```

Response `201 Created`:

```json
{
  "success": true,
  "data": {
    "customer_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "product_id": "f9e8d7c6-b5a4-3210-fedc-ba0987654321",
    "favorite_status": true
  }
}
```

Response `422` — validation error:

```json
{
  "message": "The customer id field is required. (and 1 more error)",
  "errors": {
    "customer_id": ["The customer id field is required."],
    "product_id": ["The product id field is required."]
  }
}
```

Response `404` — สินค้าไม่พบหรือไม่ได้ publish:

```json
{
  "message": "No query results for model [App\\Models\\Product]."
}
```

หมายเหตุ: เรียกซ้ำด้วย product เดิมจะได้ `201` เหมือนเดิม (idempotent ผ่าน `firstOrCreate`)

---

### 1.2 ลบสินค้าโปรด

**`DELETE /browny-shop/favorites/{product_id}?customer_id={CUSTOMER_ID}`**

Response `200 OK`:

```json
{
  "success": true,
  "data": {
    "customer_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "product_id": "f9e8d7c6-b5a4-3210-fedc-ba0987654321",
    "favorite_status": false
  }
}
```

Response `422` — ไม่ส่ง customer_id:

```json
{
  "message": "The customer id field is required.",
  "errors": {
    "customer_id": ["The customer id field is required."]
  }
}
```

หมายเหตุ: ลบซ้ำหรือลบรายการที่ไม่มีอยู่แล้วยังได้ `200` + `favorite_status: false`

---

## 2. Cart Summary (แก้ไข)

### เปลี่ยนแปลง

- รองรับ **`GET`** เป็นหลัก (เดิมมีแค่ `POST`)
- เมื่อส่ง `coupon_customer_id` และคูปองใช้ได้ → response มี object **`coupon`** เต็มรูปแบบ
- ไม่ส่ง `coupon_customer_id` → ไม่มี field `coupon` ใน response

---

### 2.1 GET — จากตะกร้าลูกค้า

**`GET /browny-shop/cart/summary`**

Query params:

| Param | Required | คำอธิบาย |
|-------|----------|----------|
| `customer_id` | ใช่ | UUID ลูกค้า |
| `coupon_customer_id` | ไม่ | ID จากตาราง `coupon_customers` |
| `payment_method` | ไม่ | เช่น `qr`, `coin`, `tp_wallet` — มีผลกับ `coin_amount_required` |

```bash
curl -G "{BASE}/browny-shop/cart/summary" \
  -H "Authorization: Bearer {TOKEN}" \
  --data-urlencode "customer_id=a1b2c3d4-e5f6-7890-abcd-ef1234567890" \
  --data-urlencode "coupon_customer_id=123" \
  --data-urlencode "payment_method=qr"
```

Response `200 OK` — มีคูปอง:

```json
{
  "success": true,
  "data": {
    "subtotal": 300.0,
    "shipping_total": 25.0,
    "flash_sale_discount": 50.0,
    "product_discount": 0.0,
    "coupon_discount": 30.0,
    "total_discount": 80.0,
    "price_original": 325.0,
    "final_price": 295.0,
    "coin_amount_required": null,
    "coin_value": 10.0,
    "coupon_customer_id": 123,
    "payment_method": "qr",
    "coupon": {
      "coupon_id": 10,
      "customer_coupon_id": 123,
      "discount_target": "product",
      "discount_type": "percent",
      "value": "10.00",
      "max_discount": "100.00",
      "min_order_amount": "500.00",
      "allow_with_promotion": false,
      "allow_with_product_discount": true,
      "remaining": "1",
      "expires_at": "2026-12-31 23:59:59",
      "used_quantity": "0",
      "name": {
        "th": "ลด 10%",
        "en": "10% off",
        "zh": "九折"
      },
      "description": {
        "th": "ใช้ได้กับ Browny Shop",
        "en": "Valid for Browny Shop",
        "zh": ""
      },
      "image_url": {
        "th": "https://example.com/storage/coupons/th.jpg",
        "en": "https://example.com/storage/coupons/en.jpg",
        "zh": ""
      }
    },
    "items": [
      {
        "product_id": "f9e8d7c6-b5a4-3210-fedc-ba0987654321",
        "product_sub_id": 42,
        "quantity": 2,
        "unit_coin_price": 150.0,
        "unit_money_price": 150.0,
        "original_coin_price": 200.0,
        "original_money_price": 200.0,
        "is_flash_sale": true,
        "flash_sale_id": 5,
        "flash_sale_discount": 50.0,
        "product_discount": 0.0,
        "line_subtotal": 300.0,
        "unit_shipping_fee": 25.0,
        "line_shipping_fee": 25.0
      }
    ]
  }
}
```

Response `200 OK` — ไม่มีคูปอง (`coupon_customer_id` ไม่ส่ง):

```json
{
  "success": true,
  "data": {
    "subtotal": 300.0,
    "shipping_total": 25.0,
    "flash_sale_discount": 0.0,
    "product_discount": 0.0,
    "coupon_discount": 0.0,
    "total_discount": 0.0,
    "price_original": 325.0,
    "final_price": 325.0,
    "coin_amount_required": null,
    "coin_value": 10.0,
    "coupon_customer_id": null,
    "payment_method": null,
    "items": [
      {
        "product_id": "f9e8d7c6-b5a4-3210-fedc-ba0987654321",
        "product_sub_id": 42,
        "quantity": 2,
        "unit_coin_price": 150.0,
        "unit_money_price": 150.0,
        "original_coin_price": 150.0,
        "original_money_price": 150.0,
        "is_flash_sale": false,
        "flash_sale_id": null,
        "flash_sale_discount": 0.0,
        "product_discount": 0.0,
        "line_subtotal": 300.0,
        "unit_shipping_fee": 25.0,
        "line_shipping_fee": 25.0
      }
    ]
  }
}
```

Response `200 OK` — `payment_method=coin`:

```json
{
  "success": true,
  "data": {
    "subtotal": 300.0,
    "shipping_total": 25.0,
    "flash_sale_discount": 0.0,
    "product_discount": 0.0,
    "coupon_discount": 0.0,
    "total_discount": 0.0,
    "price_original": 325.0,
    "final_price": 325.0,
    "coin_amount_required": 3250.0,
    "coin_value": 10.0,
    "coupon_customer_id": null,
    "payment_method": "coin",
    "items": []
  }
}
```

Response `422` — คูปองใช้ไม่ได้:

```json
{
  "success": false,
  "message": "คูปองนี้ใช้ร่วมกับ Flash Sale ไม่ได้",
  "items": [
    {
      "product_id": "f9e8d7c6-b5a4-3210-fedc-ba0987654321",
      "product_sub_id": 42,
      "quantity": 2,
      "unit_coin_price": 150.0,
      "unit_money_price": 150.0,
      "original_coin_price": 200.0,
      "original_money_price": 200.0,
      "is_flash_sale": true,
      "flash_sale_id": 5,
      "flash_sale_discount": 50.0,
      "product_discount": 0.0,
      "line_subtotal": 300.0,
      "unit_shipping_fee": 25.0,
      "line_shipping_fee": 25.0
    }
  ]
}
```

---

### 2.2 POST — จาก items ที่ส่งมาเอง (ยังใช้ได้)

**`POST /browny-shop/cart/summary`**

Request body:

```json
{
  "customer_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "coupon_customer_id": 123,
  "payment_method": "coin",
  "items": [
    { "product_sub_id": 42, "quantity": 2 }
  ]
}
```

Response รูปแบบเดียวกับ GET ด้านบน

---

## 3. Checkout (แก้ไข — ยกเลิก Draft)

### Flow ใหม่

```
ตะกร้า → GET cart/summary (preview) → POST checkout/confirm → ชำระเงิน
```

- **ไม่มี draft** อีกต่อไป — กด Back จากหน้า summary = ยกเลิกฝั่ง client ไม่ต้องเรียก API
- **`POST /checkout/draft`** และ **`PATCH /checkout/{order_id}`** ถูกยกเลิก

---

### 3.1 ยืนยันสั่งซื้อ (ใหม่ — แนะนำ)

**`POST /browny-shop/checkout/confirm`**

Request body:

```json
{
  "customer_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "coupon_customer_id": 123,
  "payment_method": "qr",
  "customer_address_id": 1
}
```

| Field | Required | คำอธิบาย |
|-------|----------|----------|
| `customer_id` | ใช่ | UUID ลูกค้า |
| `payment_method` | ใช่ | `qr`, `wechat`, `coin`, `tp_wallet`, ฯลฯ |
| `customer_address_id` | ใช่ | ID ที่อยู่จัดส่ง |
| `coupon_customer_id` | ไม่ | ID คูปองลูกค้า |

---

#### Response `200` — ชำระด้วย QR (PromptPay)

```json
{
  "success": true,
  "data": {
    "id": "c3d4e5f6-a7b8-9012-cdef-345678901234",
    "customer_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "status": "pending_payment",
    "payment_method": "qr",
    "payment_status": "pending",
    "payment_ref": "202605301234567",
    "subtotal": 300.0,
    "shipping_total": 25.0,
    "flash_sale_discount": 0.0,
    "product_discount": 0.0,
    "coupon_discount": 30.0,
    "discount_amount": 30.0,
    "price_original": 325.0,
    "price_final": 295.0,
    "coin_amount_used": null,
    "coin_value": 10.0,
    "expires_at": "2026-05-30 18:00:00",
    "paid_at": null,
    "receipt_no": null,
    "customer_address_id": 1,
    "shipping_address": {
      "id": 1,
      "recipient_name": "สมชาย ใจดี",
      "first_name": "สมชาย",
      "last_name": "ใจดี",
      "phone": "0812345678",
      "zipcode": "10110",
      "province": "กรุงเทพมหานคร",
      "district": "ปทุมวัน",
      "subdistrict": "ลุมพินี",
      "address": "123 ถนนสุขุมวิท",
      "full_address": "123 ถนนสุขุมวิท ลุมพินี ปทุมวัน กรุงเทพมหานคร 10110",
      "country": "ประเทศไทย",
      "note": null
    },
    "items": [
      {
        "product_id": "f9e8d7c6-b5a4-3210-fedc-ba0987654321",
        "product_sub_id": 42,
        "quantity": 2,
        "unit_coin_price": 150.0,
        "unit_money_price": 150.0,
        "line_subtotal": 300.0,
        "unit_shipping_fee": 25.0,
        "is_flash_sale": false
      }
    ],
    "summary": {
      "success": true,
      "subtotal": 300.0,
      "shipping_total": 25.0,
      "flash_sale_discount": 0.0,
      "product_discount": 0.0,
      "coupon_discount": 30.0,
      "total_discount": 30.0,
      "price_original": 325.0,
      "final_price": 295.0,
      "coin_amount_required": null,
      "coin_value": 10.0,
      "coupon_customer_id": 123,
      "payment_method": "qr",
      "coupon": {
        "coupon_id": 10,
        "customer_coupon_id": 123,
        "discount_target": "product",
        "discount_type": "percent",
        "value": "10.00",
        "max_discount": "100.00",
        "min_order_amount": "500.00",
        "allow_with_promotion": false,
        "allow_with_product_discount": true,
        "remaining": "1",
        "expires_at": "2026-12-31 23:59:59",
        "used_quantity": "0",
        "name": { "th": "ลด 10%", "en": "10% off", "zh": "" },
        "description": { "th": "", "en": "", "zh": "" },
        "image_url": { "th": "", "en": "", "zh": "" }
      },
      "items": []
    },
    "payment_url": "https://example.com/pay/browny-shop/202605301234567",
    "response_payload": {
      "qrcode": "00020101021229370016A000000677010112011300668999999999530376454032755802TH6304ABCD"
    }
  }
}
```

**Frontend:** ใช้ `response_payload.qrcode` (หรือ `response_payload.wechat` สำหรับ WeChat) render QR โดยตรง — ไม่ต้อง capture จาก URL รูปภาพ  
**รูปแบบเดียวกับ machine-order QR integration**

---

#### Response `200` — ชำระด้วย Browny Coin (instant paid)

```json
{
  "success": true,
  "data": {
    "id": "c3d4e5f6-a7b8-9012-cdef-345678901234",
    "customer_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "status": "paid",
    "payment_method": "coin",
    "payment_status": "paid",
    "payment_ref": "202605301234568",
    "subtotal": 300.0,
    "shipping_total": 25.0,
    "flash_sale_discount": 0.0,
    "product_discount": 0.0,
    "coupon_discount": 0.0,
    "discount_amount": 0.0,
    "price_original": 325.0,
    "price_final": 325.0,
    "coin_amount_used": 3250.0,
    "coin_value": 10.0,
    "expires_at": "2026-05-30 18:00:00",
    "paid_at": "2026-05-30 13:05:22",
    "receipt_no": "BNS20260530-130522123456",
    "customer_address_id": 1,
    "shipping_address": {
      "id": 1,
      "recipient_name": "สมชาย ใจดี",
      "first_name": "สมชาย",
      "last_name": "ใจดี",
      "phone": "0812345678",
      "zipcode": "10110",
      "province": "กรุงเทพมหานคร",
      "district": "ปทุมวัน",
      "subdistrict": "ลุมพินี",
      "address": "123 ถนนสุขุมวิท",
      "full_address": "123 ถนนสุขุมวิท ลุมพินี ปทุมวัน กรุงเทพมหานคร 10110",
      "country": "ประเทศไทย",
      "note": null
    },
    "items": [
      {
        "product_id": "f9e8d7c6-b5a4-3210-fedc-ba0987654321",
        "product_sub_id": 42,
        "quantity": 2,
        "unit_coin_price": 150.0,
        "unit_money_price": 150.0,
        "line_subtotal": 300.0,
        "unit_shipping_fee": 25.0,
        "is_flash_sale": false
      }
    ],
    "summary": {
      "success": true,
      "subtotal": 300.0,
      "shipping_total": 25.0,
      "flash_sale_discount": 0.0,
      "product_discount": 0.0,
      "coupon_discount": 0.0,
      "total_discount": 0.0,
      "price_original": 325.0,
      "final_price": 325.0,
      "coin_amount_required": 3250.0,
      "coin_value": 10.0,
      "coupon_customer_id": null,
      "payment_method": "coin",
      "items": []
    },
    "payment_url": null,
    "response_payload": {
      "method": "coin",
      "amount": 325.0,
      "coin_amount_used": 3250.0
    }
  }
}
```

---

#### Response `200` — ยอด 0 บาท (instant paid / free)

```json
{
  "success": true,
  "data": {
    "id": "c3d4e5f6-a7b8-9012-cdef-345678901234",
    "customer_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "status": "paid",
    "payment_method": "qr",
    "payment_status": "paid",
    "payment_ref": "202605301234569",
    "subtotal": 0.0,
    "shipping_total": 0.0,
    "flash_sale_discount": 0.0,
    "product_discount": 0.0,
    "coupon_discount": 0.0,
    "discount_amount": 0.0,
    "price_original": 0.0,
    "price_final": 0.0,
    "coin_amount_used": null,
    "coin_value": 10.0,
    "expires_at": "2026-05-30 18:00:00",
    "paid_at": "2026-05-30 13:05:22",
    "receipt_no": "BNS20260530-130522654321",
    "customer_address_id": 1,
    "shipping_address": {},
    "items": [],
    "summary": {},
    "payment_url": null,
    "response_payload": {
      "method": "free",
      "amount": 0,
      "coin_amount_used": null
    }
  }
}
```

---

#### Response `200` — ชำระด้วย Wallet (instant paid)

```json
{
  "success": true,
  "data": {
    "id": "c3d4e5f6-a7b8-9012-cdef-345678901234",
    "status": "paid",
    "payment_method": "tp_wallet",
    "payment_status": "paid",
    "price_final": 295.0,
    "payment_url": null,
    "response_payload": {
      "method": "wallet",
      "amount": 295.0,
      "coin_amount_used": null
    }
  }
}
```

---

#### Response `422` — error ต่างๆ

ตะกร้าว่าง:

```json
{
  "success": false,
  "message": "ตะกร้าว่าง"
}
```

ไม่มีที่อยู่จัดส่ง:

```json
{
  "success": false,
  "message": "กรุณาเลือกที่อยู่จัดส่ง"
}
```

สต็อกไม่พอ:

```json
{
  "success": false,
  "message": "สต็อกไม่พอสำหรับ SKU #42"
}
```

Coin ไม่พอ:

```json
{
  "success": false,
  "message": "จำนวน Browny Coin ไม่เพียงพอ"
}
```

สร้าง QR ไม่ได้:

```json
{
  "success": false,
  "message": "ไม่สามารถสร้าง QR Code ได้"
}
```

---

### 3.2 ยืนยันด้วย Order ID (legacy — ยังใช้ได้)

**`POST /browny-shop/checkout/{order_id}/confirm`**

Request body:

```json
{
  "customer_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "customer_address_id": 1
}
```

- ต้องส่ง **`customer_id`** เพื่อ verify ownership
- Response รูปแบบเดียวกับ `POST /checkout/confirm` รวม **`response_payload`** สำหรับ QR

Response `422` — order ไม่ใช่ของ customer หรือไม่พบ:

```json
{
  "message": "No query results for model [App\\Models\\BrownyShopOrder]."
}
```

---

### 3.3 ดู Order รอชำระ (แก้ไข)

**`GET /browny-shop/checkout/{order_id}?customer_id={CUSTOMER_ID}`**

### เปลี่ยนแปลง

- **บังคับ** query `customer_id` — ตรวจสอบว่า order เป็นของลูกค้าคนนั้น
- คืนได้เฉพาะ order สถานะ **`pending_payment`** เท่านั้น (ไม่ใช่ draft อีกต่อไป)

Response `200 OK`:

```json
{
  "success": true,
  "data": {
    "id": "c3d4e5f6-a7b8-9012-cdef-345678901234",
    "customer_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "status": "pending_payment",
    "payment_method": "qr",
    "payment_status": "pending",
    "payment_ref": "202605301234567",
    "subtotal": 300.0,
    "shipping_total": 25.0,
    "flash_sale_discount": 0.0,
    "product_discount": 0.0,
    "coupon_discount": 30.0,
    "discount_amount": 30.0,
    "price_original": 325.0,
    "price_final": 295.0,
    "coin_amount_used": null,
    "coin_value": 10.0,
    "expires_at": null,
    "paid_at": null,
    "receipt_no": null,
    "customer_address_id": 1,
    "shipping_address": {
      "id": 1,
      "recipient_name": "สมชาย ใจดี",
      "first_name": "สมชาย",
      "last_name": "ใจดี",
      "phone": "0812345678",
      "zipcode": "10110",
      "province": "กรุงเทพมหานคร",
      "district": "ปทุมวัน",
      "subdistrict": "ลุมพินี",
      "address": "123 ถนนสุขุมวิท",
      "full_address": "123 ถนนสุขุมวิท ลุมพินี ปทุมวัน กรุงเทพมหานคร 10110",
      "country": "ประเทศไทย",
      "note": null
    },
    "items": [
      {
        "product_id": "f9e8d7c6-b5a4-3210-fedc-ba0987654321",
        "product_sub_id": 42,
        "quantity": 2,
        "unit_coin_price": 150.0,
        "unit_money_price": 150.0,
        "line_subtotal": 300.0,
        "unit_shipping_fee": 25.0,
        "is_flash_sale": false
      }
    ],
    "summary": {
      "success": true,
      "subtotal": 300.0,
      "shipping_total": 25.0,
      "flash_sale_discount": 0.0,
      "product_discount": 0.0,
      "coupon_discount": 30.0,
      "total_discount": 30.0,
      "price_original": 325.0,
      "final_price": 295.0,
      "coin_amount_required": null,
      "coin_value": 10.0,
      "coupon_customer_id": 123,
      "payment_method": "qr",
      "items": []
    }
  }
}
```

Response `404` — ไม่ใช่ pending_payment หรือ customer ไม่ตรง:

```json
{
  "success": false,
  "message": "ไม่พบคำสั่งซื้อที่รอชำระเงิน"
}
```

Response `404` — order ไม่ใช่ของ customer:

```json
{
  "message": "No query results for model [App\\Models\\BrownyShopOrder]."
}
```

---

## 4. Endpoints ที่ยกเลิก (30 พ.ค. 2026)

| Method | Endpoint | ทางเลือกใหม่ |
|--------|----------|-------------|
| `POST` | `/browny-shop/checkout/draft` | ใช้ `GET /cart/summary` preview แล้ว `POST /checkout/confirm` |
| `PATCH` | `/browny-shop/checkout/{order_id}` | เปลี่ยน coupon/payment ที่หน้า summary ก่อน confirm |

---

## 5. Migration สำหรับ Frontend

| เดิม | ใหม่ |
|------|------|
| `POST /checkout/draft` → `PATCH` → `POST /{id}/confirm` | `POST /checkout/confirm` ครั้งเดียว |
| `POST /cart/summary` | `GET /cart/summary?customer_id=...` |
| ดึง QR จาก payment page URL | ใช้ `response_payload.qrcode` จาก confirm response |
| `GET /checkout/{id}` ไม่ต้องส่ง customer_id | ต้องส่ง `?customer_id=` และใช้กับ pending_payment เท่านั้น |

---

เอกสาร API ฉบับเต็ม: [`browny-shop-api.md`](./browny-shop-api.md)


---

## 1. Pending payment ต่อลูกค้า (เพิ่มใหม่)

ใช้เมื่อ app เปิดใหม่และไม่มี `order_id` ใน memory — ดึง order รอชำระ **ล่าสุด 1 รายการ** ต่อ customer

**`GET /browny-shop/pending-payment?customer_id={CUSTOMER_ID}`**

```bash
curl -X GET "{BASE}/browny-shop/pending-payment?customer_id={CUSTOMER_ID}" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Accept: application/json"
```

### Response — ไม่มี order รอชำระ

```json
{
  "success": true,
  "data": {
    "has_pending": false
  }
}
```

### Response — มี order รอชำระ

```json
{
  "success": true,
  "data": {
    "has_pending": true,
    "order_id": "c3d4e5f6-a7b8-9012-cdef-345678901234",
    "payment_ref": "202605301234567",
    "status": "pending_payment"
  }
}
```

### กฎธุรกิจ

- เลือก order ที่ `status = pending_payment` และ `payment_status = pending`
- เรียง `requested_at` แล้ว `created_at` จากใหม่ไปเก่า — คืน **รายการล่าสุดเพียง 1**
- ถ้า order หมดอายุ (`expires_at` ผ่านแล้ว) ถือว่าไม่มี pending → `has_pending: false`
- หลังได้ `order_id` ให้เรียก `GET /checkout/{order_id}` เพื่อดึง QR และ summary เต็ม

### Flow แนะนำ (Frontend)

```
เปิด app
  → GET /pending-payment?customer_id=
  → has_pending = false → หน้าปกติ
  → has_pending = true
       → GET /checkout/{order_id}?customer_id=
       → แสดง QR จาก response_payload.qrcode
```

---

## 2. GET checkout — คืน response_payload (แก้ไข)

**`GET /browny-shop/checkout/{order_id}?customer_id={CUSTOMER_ID}`**

เดิมคืนเฉพาะข้อมูล order + `summary` — ตอนนี้คืน **`response_payload`** และ **`payment_url`** เหมือน `POST /checkout/confirm` เพื่อให้กลับมาหน้า QR ได้โดยไม่ต้อง confirm ซ้ำ

### ฟิลด์ที่เพิ่มใน `data`

| Field | คำอธิบาย |
|-------|----------|
| `response_payload` | Raw JSON จาก GB gateway (`qrcode` / `wechat`) หรือ `null` ถ้ายังไม่มี |
| `payment_url` | URL หน้า web payment (`null` ถ้าชำระแล้ว) |

### ตัวอย่าง Response `200` (QR)

```json
{
  "success": true,
  "data": {
    "id": "c3d4e5f6-a7b8-9012-cdef-345678901234",
    "customer_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "status": "pending_payment",
    "payment_method": "qr",
    "payment_status": "pending",
    "payment_ref": "202605301234567",
    "price_final": 295.0,
    "expires_at": "2026-05-30 18:00:00",
    "payment_url": "{APP_URL}/pay/browny-shop/202605301234567",
    "response_payload": {
      "qrcode": "00020101021229370016A000000677010112011300668999999999530376454032755802TH6304ABCD"
    },
    "items": [],
    "summary": {}
  }
}
```

`response_payload` เก็บใน DB ตั้งแต่ confirm — GET อ่านค่าเดิม ไม่สร้าง QR ใหม่

### Response `404`

Order ไม่ใช่ `pending_payment` หรือไม่ใช่ของ customer:

```json
{
  "success": false,
  "message": "ไม่พบคำสั่งซื้อที่รอชำระเงิน"
}
```

---

## 3. รายการสินค้าโปรด (เพิ่มใหม่)

**`GET /browny-shop/favorites?customer_id={CUSTOMER_ID}`**

Query (ไม่บังคับ):

| Query | คำอธิบาย |
|-------|----------|
| `lang` | locale เดียว (เช่น `th`) — ถ้าไม่ส่ง คืนทุก locale ตาม config |

```bash
curl -X GET "{BASE}/browny-shop/favorites?customer_id={CUSTOMER_ID}&lang=th" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Accept: application/json"
```

### Response `200` — มีรายการ

```json
{
  "success": true,
  "data": {
    "customer_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "items": [
      {
        "id": "f9e8d7c6-b5a4-3210-fedc-ba0987654321",
        "is_free_shipping": false,
        "favorite_status": true,
        "has_flash_sale": false,
        "unit": { "th": "ชิ้น", "en": "pc", "zh": "" },
        "translations": [],
        "product_subs": [],
        "main_image_url": "https://example.com/storage/products/a.jpg"
      }
    ]
  }
}
```

รูปแบบ `items[]` เหมือน product list API (`ProductApiFormatter`) — ทุกรายการมี `favorite_status: true`

### Response `200` — ว่าง

```json
{
  "success": true,
  "data": {
    "customer_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "items": []
  }
}
```

### หมายเหตุ

- แสดงเฉพาะสินค้า `status = published` ที่ยังอยู่ใน `product_favorites`
- เรียงตามวันที่กดโปรด (ใหม่สุดก่อน)
- สินค้าที่ถูกลบหรือ unpublish จะไม่ปรากฏใน list แต่แถวใน `product_favorites` อาจยังอยู่

---
## 4. Cart summary — shipping estimate (แก้ไข)

**`GET /browny-shop/cart/summary`** และ **`POST /browny-shop/cart/summary`**

เพิ่ม optional param **`customer_address_id`** สำหรับแสดงค่าส่ง/ยอดรวมโดยประมาณก่อน checkout

### Param ที่เพิ่ม

| Param | Required | คำอธิบาย |
|-------|----------|----------|
| `customer_address_id` | ไม่ | ID ที่อยู่จัดส่ง — ต้องเป็นของ `customer_id` ที่ส่งมา |

### Response fields ที่เพิ่ม

| Field | คำอธิบาย |
|-------|----------|
| `shipping_is_estimate` | `true` เสมอ — ให้ frontend แสดง "ขนส่งโดยประมาณ" |
| `customer_address_id` | echo กลับเมื่อส่ง address มา |
| `shipping_address` | snapshot ที่อยู่ (ชื่อผู้รับ, เบอร์, จังหวัด ฯลฯ) |

ค่าส่งยังคำนวณจาก SKU/product (`shipping_fee`, `is_free_shipping`, flash sale) — **ยังไม่ผูก zone ตามที่อยู่**

### ตัวอย่าง — Product Detail (POST + items 1 รายการ)

```bash
curl -X POST "{BASE}/browny-shop/cart/summary" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_id": "{CUSTOMER_ID}",
    "customer_address_id": 1,
    "items": [{ "product_sub_id": 42, "quantity": 1 }]
  }'
```

### ตัวอย่าง — Summary page (GET จากตะกร้า)

```bash
curl -G "{BASE}/browny-shop/cart/summary" \
  -H "Authorization: Bearer {TOKEN}" \
  --data-urlencode "customer_id={CUSTOMER_ID}" \
  --data-urlencode "customer_address_id=1" \
  --data-urlencode "payment_method=qr"
```

### Response `422` — ที่อยู่ไม่ใช่ของลูกค้า

```json
{
  "success": false,
  "message": "ไม่พบที่อยู่จัดส่งของลูกค้านี้"
}
```

---

## 5. Receipt — lucky_no / lucky_image / qr_image (แก้ไข)

**`GET /browny-shop/orders/{ORDER_ID}/receipt`**

เพิ่มฟิลด์เลขนำโชคและ QR code เหมือน machine order receipt

| Field | คำอธิบาย |
|-------|----------|
| `lucky_no` | เลขนำโชค 1–99 (สุ่มตอนชำระสำเร็จ) |
| `lucky_image` | URL รูป `{APP_URL}/images/lucky_no/{lucky_no}.png` |
| `qr_image` | URL QR code `{APP_URL}/storage/qrcodes/{ORDER_ID}.png` |

Order เก่าที่ paid แล้วแต่ยังไม่มี `lucky_no` จะถูก backfill ตอนเรียก receipt ครั้งแรก

```json
{
  "lucky_no": "42",
  "lucky_image": "{APP_URL}/images/lucky_no/42.png",
  "qr_image": "{APP_URL}/storage/qrcodes/{ORDER_ID}.png"
}
```

---

## Endpoints ที่เกี่ยวข้อง (เดิม)

| Method | Endpoint |
|--------|----------|
| `POST` | `/browny-shop/favorites` |
| `DELETE` | `/browny-shop/favorites/{product_id}` |
| `POST` | `/browny-shop/checkout/confirm` |
| `GET` | `{APP_URL}/api/payment/browny-shop/status/{PAYMENT_REF}` |

---

# Browny Shop API — Changelog (Order History, Detail, Review, Bonus)

**วันที่:** 31 พฤษภาคม 2026  
**Base URL:** `{APP_URL}/api`  
**Auth:** `Authorization: Bearer {TOKEN}`


---

## สรุปการเปลี่ยนแปลง

| สถานะ | Method | Endpoint |
|-------|--------|----------|
| แก้ไข | `GET` | `/browny-shop/orders` |
| เพิ่มใหม่ | `GET` | `/browny-shop/orders/{order_id}` |
| แก้ไข | `GET` | `/browny-shop/orders/{order_id}/receipt` |
| เพิ่มใหม่ | `POST` | `/browny-shop/orders/{order_id}/review` |

**Migration:** `review_score`, `tracking_number`, `shipped_at`, `delivered_at` บน `browny_shop_orders`

---

## 1. Order history (`GET /browny-shop/orders`)

### Query

- `customer_id` (required)
- `page`, `per_page`, `date`, `start_date`, `end_date` (optional)

### กฎ filter

- รวม `status`: `pending_payment`, `paid`, `cancelled`
- ไม่รวม `draft`, `expired`

### Mock response

```json
{
  "success": true,
  "data": [
    {
      "type": "browny_shop_order",
      "order_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "receipt_no": "BS-20260531-0001",
      "status": "delivered",
      "status_label": {
        "th": "จัดส่งแล้ว",
        "en": "Delivered",
        "zh": "已发货"
      },
      "delivered_at": "2026-10-14 15:30:00",
      "delivery_date": "2026-10-14",
      "receipt_at": "2026-10-10 12:00:00",
      "payment_method": {
        "key": "qr",
        "name": { "th": "QR Code", "en": "QR Code", "zh": "二维码" }
      },
      "amount": "599.00",
      "price_final": "599.00",
      "item_count": 3,
      "line_count": 2,
      "title": {
        "th": "เสื้อยืด Browny (+1)",
        "en": "Browny T-Shirt (+1)",
        "zh": "Browny T-Shirt (+1)"
      },
      "preview_image": "https://example.com/storage/products/shirt.png",
      "items": [
        {
          "name": { "th": "เสื้อยืด Browny", "en": "Browny T-Shirt", "zh": "Browny T-Shirt" },
          "image_url": "https://example.com/storage/products/shirt.png",
          "quantity": 2
        },
        {
          "name": { "th": "กางเกง Browny", "en": "Browny Pants", "zh": "Browny Pants" },
          "image_url": "https://example.com/storage/products/pants.png",
          "quantity": 1
        }
      ],
      "sort_at": "2026-10-14 15:30:00"
    },
    {
      "order_id": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
      "receipt_no": null,
      "status": "pending_payment",
      "status_label": {
        "th": "กรุณาชำระเงิน",
        "en": "Awaiting payment",
        "zh": "待付款"
      },
      "delivered_at": null,
      "delivery_date": null,
      "amount": "299.00",
      "price_final": "299.00",
      "item_count": 1,
      "line_count": 1,
      "items": [
        {
          "name": { "th": "หมวก Browny", "en": "Browny Cap", "zh": "Browny Cap" },
          "image_url": "https://example.com/storage/products/cap.png",
          "quantity": 1
        }
      ],
      "preview_image": "https://example.com/storage/products/cap.png",
      "sort_at": "2026-10-12 09:00:00"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total": 2,
    "last_page": 1
  }
}
```

### UI status mapping

| DB state | `status` |
|----------|----------|
| `cancelled` | `cancelled` |
| not paid | `pending_payment` |
| paid + `delivered_at` set | `delivered` |
| paid, no delivery | `pending_shipment` |

---

## 2. Order detail (`GET /browny-shop/orders/{order_id}`)

### Query

- `customer_id` (required) — ต้องเป็นเจ้าของ order

### Mock response (paid, รอจัดส่ง)

```json
{
  "success": true,
  "data": {
    "type": "browny_shop_order",
    "order_id": "019db31a-8688-7100-9a0d-58f0d0394224",
    "payment_ref": "202605311234567",
    "receipt_no": "BS-20260531-0001",
    "status": "pending_shipment",
    "status_label": {
      "th": "รอจัดส่ง",
      "en": "Awaiting shipment",
      "zh": "待发货"
    },
    "status_steps": {
      "ordered": {
        "done": true,
        "at": "2026-05-31 10:00:00"
      },
      "paid": {
        "done": true,
        "at": "2026-05-31 10:05:00"
      },
      "shipping": {
        "done": true,
        "at": "2026-05-31 14:00:00"
      }
    },
    "tracking_number": "TH123456789",
    "price_original": "650.00",
    "price_final": "599.00",
    "amount": "599.00",
    "discount_amount": "51.00",
    "total_quantity": 3,
    "item_count": 3,
    "payment_method": "qr",
    "payment_icon": "https://gateway.abgroup.co.th/assets/images/customerNotificationIconPaymnet/qr.png",
    "payment_channel": "qr",
    "payment_display": {
      "th": "QR Code",
      "en": "QR Code",
      "zh": "二维码"
    },
    "created_at": "2026-05-31 10:00:00",
    "paid_at": "2026-05-31 10:05:00",
    "shipped_at": "2026-05-31 14:00:00",
    "delivered_at": null,
    "delivery_date": null,
    "receipt_at": "2026-05-31 10:05:00",
    "review_score": null,
    "bonus": "5500.00",
    "qr_image": "https://gateway.abgroup.co.th/storage/qrcodes/019db31a-8688-7100-9a0d-58f0d0394224.png",
    "shipping_address": {
      "id": 1,
      "recipient_name": "สมชาย ใจดี",
      "first_name": "สมชาย",
      "last_name": "ใจดี",
      "phone": "0812345678",
      "zipcode": "10110",
      "province": "กรุงเทพมหานคร",
      "district": "คลองเตย",
      "subdistrict": "คลองเตย",
      "address": "123 ถ.สุขุมวิท",
      "full_address": "123 ถ.สุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพฯ 10110",
      "country": "ประเทศไทย",
      "note": null
    },
    "summary": {
      "quantity": {
        "wording": {
          "th": "จำนวน",
          "en": "Quantity",
          "zh": "数量"
        },
        "amount": "3"
      },
      "subtotal": {
        "wording": {
          "th": "ยอดรวมสินค้า",
          "en": "Subtotal",
          "zh": "商品合计"
        },
        "amount": "625.00"
      },
      "discount": {
        "wording": {
          "th": "ส่วนลด",
          "en": "Discount",
          "zh": "折扣"
        },
        "amount": "-26.00"
      },
      "flash_sale_discount": {
        "wording": {
          "th": "Flash Sale",
          "en": "Flash Sale",
          "zh": "闪购优惠"
        },
        "amount": "-26.00"
      },
      "coupon_discount": {
        "wording": {
          "th": "คูปองและรหัสคูปอง",
          "en": "Coupon & code",
          "zh": "优惠券及代码"
        },
        "amount": "",
        "code": "",
        "coupon_name": {
          "th": "",
          "en": "",
          "zh": ""
        }
      },
      "shipping": {
        "wording": {
          "th": "การจัดส่ง",
          "en": "Shipping",
          "zh": "配送"
        },
        "amount": "25.00"
      },
      "total": {
        "wording": {
          "th": "ยอดชำระทั้งหมด",
          "en": "Total payment",
          "zh": "应付总额"
        },
        "amount": "599.00"
      }
    },
    "items": [
      {
        "product_id": "019db31a-8688-7100-9a0d-58f0d0394224",
        "product_sub_id": 16,
        "quantity": 1,
        "name": {
          "th": "เสื้อยืด Browny",
          "en": "Browny T-Shirt",
          "zh": "Browny T-Shirt"
        },
        "unit": {
          "th": "ตัว",
          "en": "pc",
          "zh": "pc"
        },
        "image_url": "https://gateway.abgroup.co.th/storage/products/tshirt-red.jpg",
        "bonus": "2750.00",
        "is_flash_sale": true,
        "unit_coin_price": 2750,
        "unit_money_price": 249,
        "original_coin_price": 2750,
        "original_money_price": 275,
        "flash_sale_id": 5,
        "flash_sale_discount": 26,
        "product_discount": 0,
        "line_subtotal": 249,
        "unit_shipping_fee": 25,
        "line_shipping_fee": 25
      },
      {
        "product_id": "019db31a-9999-7100-9a0d-58f0d0399999",
        "product_sub_id": 42,
        "quantity": 2,
        "name": {
          "th": "กระเป๋าผ้า",
          "en": "Canvas Bag",
          "zh": "Canvas Bag"
        },
        "unit": {
          "th": "ใบ",
          "en": "pc",
          "zh": "pc"
        },
        "image_url": "https://gateway.abgroup.co.th/storage/products/bag.jpg",
        "bonus": "2750.00",
        "is_flash_sale": false,
        "unit_coin_price": 1375,
        "unit_money_price": 137.5,
        "original_coin_price": 1375,
        "original_money_price": 137.5,
        "flash_sale_id": null,
        "flash_sale_discount": 0,
        "product_discount": 0,
        "line_subtotal": 275,
        "unit_shipping_fee": 0,
        "line_shipping_fee": 0
      }
    ],
    "call_center": "099-635-1211",
    "line_link": "https://line.me/R/ti/p/%40browny"
  }
}
```

---

## 3. Receipt (`GET /browny-shop/orders/{order_id}/receipt`)

เพิ่มฟิลด์ (ไม่ breaking ฟิลด์เดิม):

- `review_score`, `bonus`, `items[].bonus`
- `status`, `status_label`, `status_steps`
- `tracking_number`, `created_at`, `shipped_at`, `delivered_at`, `delivery_date`
- `payment_method` (key string)

### Mock snippet

```json
{
  "type": "browny_shop_order",
  "order_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "status": "delivered",
  "review_score": 5,
  "bonus": "255.00",
  "tracking_number": "TH123456789TH",
  "delivered_at": "2026-10-14 15:30:00",
  "items": [
    {
      "quantity": 2,
      "line_subtotal": "500.00",
      "bonus": "100.00"
    }
  ]
}
```

**Bonus calculation:** `sum(unit_coin_price × quantity)` จาก snapshot ใน `browny_shop_order_items` (ยังไม่มี webhook แจก coin จริง)

---

## 4. Review (`POST /browny-shop/orders/{order_id}/review`)

### Body

```json
{ "score": 5 }
```

### Success

```json
{
  "status": "success",
  "message": "รีวิวร้านสำเร็จ"
}
```

### Errors

| HTTP | message |
|------|---------|
| 400 | คำสั่งนี้ได้รีวิวแล้ว |
| 400 | คำสั่งนี้ยังไม่ได้ชำระเงิน |
| 404 | ไม่พบข้อมูลคำสั่งที่ต้องการ |

---


