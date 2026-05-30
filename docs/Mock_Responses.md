## Mock responses

Sample JSON for frontend / Postman / UI prototyping. Numbers are consistent across endpoints.

| Field | Value |
|-------|-------|
| Subtotal | 748.00 |
| Shipping (40 + 25, per SKU — not × qty) | 65.00 |
| Flash + product discount | 69.00 |
| Coupon discount | 50.00 |
| **Final price** | **763.00** |
| Coin required (rate 10) | 7,630 |

### List banners

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Flash Sale สิ้นเดือน",
      "image_url": "http://localhost/ABI_Backend/public/storage/banners/flash-sale-may.jpg",
      "first_login_only": false,
      "start_at": "2026-05-01 00:00:00",
      "end_at": "2026-05-31 23:59:59",
      "sort_order": 1
    },
    {
      "id": 2,
      "title": "Welcome ลูกค้าใหม่",
      "image_url": "http://localhost/ABI_Backend/public/storage/banners/welcome-new.jpg",
      "first_login_only": true,
      "start_at": null,
      "end_at": null,
      "sort_order": 2
    }
  ]
}
```

### Title image

```json
{
  "success": true,
  "data": {
    "image_url": "http://localhost/ABI_Backend/public/storage/browny-shop/title-header.png"
  }
}
```

### Cart summary — QR + coupon

```json
{
  "success": true,
  "data": {
    "success": true,
    "subtotal": 748.00,
    "shipping_total": 65.00,
    "flash_sale_discount": 49.00,
    "product_discount": 20.00,
    "coupon_discount": 50.00,
    "total_discount": 119.00,
    "price_original": 813.00,
    "final_price": 763.00,
    "coin_amount_required": null,
    "coin_value": 10.00,
    "coupon_customer_id": 123,
    "payment_method": "qr",
    "items": [
      {
        "product_id": "11111111-1111-1111-1111-111111111111",
        "product_sub_id": 101,
        "quantity": 2,
        "unit_coin_price": 299.00,
        "unit_money_price": 299.00,
        "original_coin_price": 299.00,
        "original_money_price": 299.00,
        "is_flash_sale": false,
        "flash_sale_id": null,
        "flash_sale_discount": 0.00,
        "product_discount": 20.00,
        "line_subtotal": 578.00,
        "unit_shipping_fee": 40.00,
        "line_shipping_fee": 40.00
      },
      {
        "product_id": "22222222-2222-2222-2222-222222222222",
        "product_sub_id": 205,
        "quantity": 1,
        "unit_coin_price": 150.00,
        "unit_money_price": 150.00,
        "original_coin_price": 199.00,
        "original_money_price": 199.00,
        "is_flash_sale": true,
        "flash_sale_id": 5,
        "flash_sale_discount": 49.00,
        "product_discount": 0.00,
        "line_subtotal": 150.00,
        "unit_shipping_fee": 25.00,
        "line_shipping_fee": 25.00
      }
    ]
  }
}
```

### Cart summary — coin (single item)

```json
{
  "success": true,
  "data": {
    "subtotal": 598.00,
    "shipping_total": 40.00,
    "flash_sale_discount": 0.00,
    "product_discount": 0.00,
    "coupon_discount": 0.00,
    "total_discount": 0.00,
    "price_original": 638.00,
    "final_price": 638.00,
    "coin_amount_required": 6380.00,
    "coin_value": 10.00,
    "payment_method": "coin",
    "items": [
      {
        "product_id": "11111111-1111-1111-1111-111111111111",
        "product_sub_id": 101,
        "quantity": 2,
        "unit_coin_price": 299.00,
        "unit_money_price": 299.00,
        "original_coin_price": 299.00,
        "original_money_price": 299.00,
        "is_flash_sale": false,
        "flash_sale_id": null,
        "flash_sale_discount": 0.00,
        "product_discount": 0.00,
        "line_subtotal": 598.00,
        "unit_shipping_fee": 40.00,
        "line_shipping_fee": 40.00
      }
    ]
  }
}
```

### Cart summary — coupon error (422)

```json
{
  "success": false,
  "message": "คูปองนี้ใช้ร่วมกับ Flash Sale ไม่ได้",
  "items": []
}
```

### Create draft (201)

```json
{
  "success": true,
  "data": {
    "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "customer_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "status": "draft",
    "payment_method": "qr",
    "payment_status": "pending",
    "payment_ref": null,
    "subtotal": 748.00,
    "shipping_total": 65.00,
    "flash_sale_discount": 49.00,
    "product_discount": 20.00,
    "coupon_discount": 50.00,
    "discount_amount": 119.00,
    "price_original": 813.00,
    "price_final": 763.00,
    "coin_amount_used": null,
    "coin_value": null,
    "expires_at": "2026-05-27 18:30:00",
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
      "address": "123 ถ.สุขุมวิท",
      "full_address": "123 ถ.สุขุมวิท แขวงลุมพินี เขตปทุมวัน กรุงเทพมหานคร 10110",
      "country": "ประเทศไทย",
      "note": "ฝากไว้ที่รปภ."
    },
    "items": [
      {
        "product_id": "11111111-1111-1111-1111-111111111111",
        "product_sub_id": 101,
        "quantity": 2,
        "unit_coin_price": 299.00,
        "unit_money_price": 299.00,
        "line_subtotal": 578.00,
        "unit_shipping_fee": 40.00,
        "is_flash_sale": false
      },
      {
        "product_id": "22222222-2222-2222-2222-222222222222",
        "product_sub_id": 205,
        "quantity": 1,
        "unit_coin_price": 150.00,
        "unit_money_price": 150.00,
        "line_subtotal": 150.00,
        "unit_shipping_fee": 25.00,
        "is_flash_sale": true
      }
    ]
  }
}
```

### Get / update draft

Same order fields as draft above, plus recalculated `summary`:

```json
{
  "success": true,
  "data": {
    "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "status": "draft",
    "payment_method": "coin",
    "payment_status": "pending",
    "subtotal": 748.00,
    "shipping_total": 65.00,
    "price_final": 763.00,
    "expires_at": "2026-05-27 18:30:00",
    "summary": {
      "success": true,
      "subtotal": 748.00,
      "shipping_total": 65.00,
      "flash_sale_discount": 49.00,
      "product_discount": 20.00,
      "coupon_discount": 50.00,
      "total_discount": 119.00,
      "price_original": 813.00,
      "final_price": 763.00,
      "coin_amount_required": 7630.00,
      "coin_value": 10.00,
      "coupon_customer_id": 123,
      "payment_method": "coin",
      "items": []
    }
  }
}
```

### Confirm — QR (pending payment)

```json
{
  "success": true,
  "data": {
    "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "status": "pending_payment",
    "payment_method": "qr",
    "payment_status": "pending",
    "payment_ref": "BS20260527001",
    "price_final": 763.00,
    "paid_at": null,
    "payment_url": "http://localhost/ABI_Backend/public/pay/browny-shop/BS20260527001"
  }
}
```

### Confirm — coin (instant paid)

```json
{
  "success": true,
  "data": {
    "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "status": "paid",
    "payment_method": "coin",
    "payment_status": "paid",
    "payment_ref": "BS20260527001",
    "price_final": 763.00,
    "coin_amount_used": 7630.00,
    "coin_value": 10.00,
    "paid_at": "2026-05-27 13:30:00",
    "receipt_no": "RCP-2026-000123",
    "payment_url": null
  }
}
```

### Confirm — errors (422)

```json
{ "success": false, "message": "กรุณาเลือกที่อยู่จัดส่ง" }
```

```json
{ "success": false, "message": "กรุณาเลือกช่องทางชำระเงิน" }
```

### Payment status — pending (412)

```json
{
  "status": "pending",
  "payment_status": "pending",
  "order_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "message": "ยังไม่ชำระเงิน"
}
```

### Payment status — paid (200)

```json
{
  "status": "success",
  "payment_status": "paid",
  "order_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "receipt_no": "RCP-2026-000123",
  "redirect": "http://localhost/ABI_Backend/public/api/browny-shop/orders/f47ac10b-58cc-4372-a567-0e02b2c3d479/receipt"
}
```

### Order history

```json
{
  "success": true,
  "data": [
    {
      "type": "browny_shop_order",
      "order_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
      "receipt_no": "RCP-2026-000123",
      "receipt_at": "2026-05-27 13:30:00",
      "payment_method": {
        "key": "coin",
        "name": {
          "th": "Browny Coin",
          "en": "Browny Coin",
          "zh": "Browny Coin"
        }
      },
      "amount": "763.00",
      "item_count": 3,
      "title": {
        "th": "น้ำยาซักผ้า Browny 2L (+1)",
        "en": "Browny Detergent 2L (+1)",
        "zh": "Browny 洗衣液 2L (+1)"
      },
      "sort_at": "2026-05-27 13:30:00"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total": 1,
    "last_page": 1
  }
}
```

### Receipt

```json
{
  "type": "browny_shop_order",
  "order_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "payment_ref": "BS20260527001",
  "receipt_no": "RCP-2026-000123",
  "total": "763.00",
  "price_original": "813.00",
  "price_final": "763.00",
  "discount_amount": "119.00",
  "total_quantity": 3,
  "payment_icon": "http://localhost/ABI_Backend/public/assets/images/customerNotificationIconPaymnet/tp_wallet.png",
  "payment_channel": "coin",
  "payment_display": {
    "th": "Browny Coin",
    "en": "Browny Coin",
    "zh": "Browny Coin"
  },
  "paid_at": "2026-05-27 13:30:00",
  "receipt_at": "2026-05-27 13:30:00",
  "coin_amount_used": "7630.00",
  "coin_value": 10.0,
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
    "address": "123 ถ.สุขุมวิท",
    "full_address": "123 ถ.สุขุมวิท แขวงลุมพินี เขตปทุมวัน กรุงเทพมหานคร 10110",
    "country": "ประเทศไทย",
    "note": "ฝากไว้ที่รปภ."
  },
  "summary": {
    "quantity": {
      "wording": { "th": "จำนวน", "en": "Quantity", "zh": "数量" },
      "amount": "3"
    },
    "subtotal": {
      "wording": { "th": "ยอดรวมสินค้า", "en": "Subtotal", "zh": "商品合计" },
      "amount": "748.00"
    },
    "discount": {
      "wording": { "th": "ส่วนลด", "en": "Discount", "zh": "折扣" },
      "amount": "-69.00"
    },
    "flash_sale_discount": {
      "wording": { "th": "Flash Sale", "en": "Flash Sale", "zh": "闪购优惠" },
      "amount": "-49.00"
    },
    "product_discount": {
      "wording": { "th": "ส่วนลดสินค้า", "en": "Product discount", "zh": "商品折扣" },
      "amount": "-20.00"
    },
    "coupon_discount": {
      "wording": { "th": "คูปองและรหัสคูปอง", "en": "Coupon & code", "zh": "优惠券及代码" },
      "amount": "-50.00",
      "code": "PROMO2026",
      "coupon_name": {
        "th": "ลด 50 บาท",
        "en": "50 THB Off",
        "zh": "减50泰铢"
      }
    },
    "shipping": {
      "wording": { "th": "การจัดส่ง", "en": "Shipping", "zh": "配送" },
      "amount": "65.00"
    },
    "total": {
      "wording": { "th": "ยอดชำระทั้งหมด", "en": "Total payment", "zh": "应付总额" },
      "amount": "763.00"
    }
  },
  "items": [
    {
      "product_id": "11111111-1111-1111-1111-111111111111",
      "product_sub_id": 101,
      "quantity": 2,
      "name": {
        "th": "น้ำยาซักผ้า Browny 2L",
        "en": "Browny Detergent 2L",
        "zh": "Browny 洗衣液 2L"
      },
      "unit": { "th": "ขวด", "en": "bottle", "zh": "瓶" },
      "image_url": "http://localhost/ABI_Backend/public/storage/products/detergent-2l.jpg",
      "unit_money_price": "289.00",
      "original_money_price": "299.00",
      "line_subtotal": "578.00",
      "flash_sale_discount": "0.00",
      "product_discount": "20.00",
      "unit_shipping_fee": "40.00",
      "is_flash_sale": false
    },
    {
      "product_id": "22222222-2222-2222-2222-222222222222",
      "product_sub_id": 205,
      "quantity": 1,
      "name": {
        "th": "น้ำยาปรับผ้านุ่ม",
        "en": "Fabric Softener",
        "zh": "柔顺剂"
      },
      "unit": { "th": "ถุง", "en": "sachet", "zh": "袋" },
      "image_url": "http://localhost/ABI_Backend/public/storage/products/softener.jpg",
      "unit_money_price": "150.00",
      "original_money_price": "199.00",
      "line_subtotal": "150.00",
      "flash_sale_discount": "49.00",
      "product_discount": "0.00",
      "unit_shipping_fee": "25.00",
      "is_flash_sale": true
    }
  ],
  "call_center": "099-635-1211",
  "line_link": "https://line.me/R/ti/p/%40browny"
}
```

### Collect coupon

```json
{
  "message": "Coupon collected successfully.",
  "coupon_customer": {
    "id": 123,
    "customer_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "coupon_id": 45,
    "quantity": 1,
    "remaining": 1,
    "assigned_at": "2026-05-27T13:00:00.000000Z",
    "used_at": null,
    "expires_at": "2026-06-26T13:00:00.000000Z",
    "source": "manual_code"
  }
}
```

### List usable Browny Shop coupons

```json
{
  "data": [
    {
      "coupon_id": 45,
      "customer_coupon_id": 123,
      "discount_target": "product",
      "discount_type": "fixed",
      "value": "50.00",
      "max_discount": null,
      "min_order_amount": "500.00",
      "allow_with_promotion": false,
      "allow_with_product_discount": true,
      "remaining": "1",
      "expires_at": "2026-06-26 13:00:00",
      "used_quantity": "0",
      "name": {
        "th": "ลด 50 บาท",
        "en": "50 THB Off",
        "zh": "减50泰铢"
      },
      "description": {
        "th": "ใช้ได้เมื่อซื้อครบ 500 บาท",
        "en": "Min. order 500 THB",
        "zh": "满500泰铢可用"
      },
      "image_url": {
        "th": "http://localhost/ABI_Backend/public/storage/coupons/promo2026-th.jpg",
        "en": "http://localhost/ABI_Backend/public/storage/coupons/promo2026-en.jpg",
        "zh": "http://localhost/ABI_Backend/public/storage/coupons/promo2026-zh.jpg"
      }
    }
  ]
}
```

### Customer cart

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "product_id": "11111111-1111-1111-1111-111111111111",
        "product_sub_id": 101,
        "quantity": 2,
        "unit_coin_price": 299.00,
        "unit_money_price": 299.00,
        "is_flash_sale": false,
        "flash_sale_id": null,
        "product_name": {
          "th": "น้ำยาซักผ้า Browny",
          "en": "Browny Detergent",
          "zh": "Browny 洗衣液"
        },
        "variant_name": { "th": "2L", "en": "2L", "zh": "2L" },
        "current_unit_coin_price": 299.00,
        "current_unit_money_price": 299.00,
        "current_is_flash_sale": false,
        "current_flash_sale_id": null,
        "price_changed": false
      }
    ],
    "totals": {
      "total_line_coin": 598.00,
      "total_line_money": 598.00,
      "computed_from": "snapshot_unit_prices"
    }
  }
}
```