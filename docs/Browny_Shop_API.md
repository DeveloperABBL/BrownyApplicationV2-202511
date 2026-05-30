# Browny Shop API

Base URL: `{APP_URL}/api`

Authentication: include API token header used by other mobile endpoints (`CheckApiToken` middleware).

Replace placeholders:
- `{BASE}` — e.g. `http://localhost/ABI_Backend/public/api`
- `{CUSTOMER_ID}` — UUID
- `{ORDER_ID}` — Browny Shop order UUID
- `{TOKEN}` — API token

---

## Content

### List banners

```bash
curl -X GET "{BASE}/browny-shop/banners?customer_id={CUSTOMER_ID}" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Accept: application/json"
```

### Title image

```bash
curl -X GET "{BASE}/browny-shop/title-image" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Accept: application/json"
```

---

## Cart summary (preview)

From customer cart:

```bash
curl -X POST "{BASE}/browny-shop/cart/summary" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "customer_id": "{CUSTOMER_ID}",
    "coupon_customer_id": null,
    "payment_method": "qr"
  }'
```

From explicit items:

```bash
curl -X POST "{BASE}/browny-shop/cart/summary" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_id": "{CUSTOMER_ID}",
    "items": [
      { "product_sub_id": 1, "quantity": 2 }
    ],
    "payment_method": "coin"
  }'
```

Response fields:
- `subtotal`, `shipping_total`, `flash_sale_discount`, `product_discount`, `coupon_discount`, `total_discount`, `price_original`, `final_price`, `coin_amount_required`, `items[]`

Shipping is **per SKU, not multiplied by quantity**.

---

## Checkout flow (cart → draft → order)

### 1. Create draft (5 hour expiry)

```bash
curl -X POST "{BASE}/browny-shop/checkout/draft" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_id": "{CUSTOMER_ID}",
    "coupon_customer_id": 123,
    "payment_method": "qr"
  }'
```

### 2. Get draft

```bash
curl -X GET "{BASE}/browny-shop/checkout/{ORDER_ID}" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Accept: application/json"
```

### 3. Update draft (coupon / payment method)

```bash
curl -X PATCH "{BASE}/browny-shop/checkout/{ORDER_ID}" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "coupon_customer_id": 123,
    "payment_method": "coin"
  }'
```

### 4. Confirm → pending payment or instant paid

Requires shipping address (`customer_address_id` from customer addresses API).

```bash
curl -X POST "{BASE}/browny-shop/checkout/{ORDER_ID}/confirm" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "customer_address_id": 1
  }'
```

Set address earlier on draft/update:

```bash
curl -X PATCH "{BASE}/browny-shop/checkout/{ORDER_ID}" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{ "customer_address_id": 1 }'
```

- `coin`, `tp_wallet`, or `final_price = 0` → paid immediately, cart cleared, stock deducted
- Other methods → returns `payment_url` for web payment page

Payment page: `{APP_URL}/pay/browny-shop/{payment_ref}`

QR API: `{APP_URL}/api/payment/browny-shop/qr/{payment_ref}`

Poll payment status (no auth):

```bash
curl -X GET "{APP_URL}/api/payment/browny-shop/status/{PAYMENT_REF}"
```

---

## Orders

### Order history (Browny Shop only)

```bash
curl -X GET "{BASE}/browny-shop/orders?customer_id={CUSTOMER_ID}&page=1&per_page=20" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Accept: application/json"
```

Also included in unified history: `GET {BASE}/customer/{CUSTOMER_ID}/order-history` (type `browny_shop_order`).

### Receipt (paid orders)

```bash
curl -X GET "{BASE}/browny-shop/orders/{ORDER_ID}/receipt" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Accept: application/json"
```

Key response fields (aligned with mobile receipt UI):

| Field                     | Description                                          |
| ------------------------- | ---------------------------------------------------- |
| `total` / `price_final`   | ยอดชำระ (ตัวเลขใหญ่ด้านบน)                               |
| `payment_ref`             | เลขอ้างอิงการชำระ                                       |
| `receipt_no`              | เลขใบเสร็จ                                            |
| `paid_at`, `receipt_at`   | วันเวลา (ISO)                                         |
| `total_quantity`          | จำนวนชิ้นรวม                                            |
| `summary.quantity`        | จำนวน (แถวสรุป)                                        |
| `summary.subtotal`        | ยอดรวมสินค้า                                           |
| `summary.discount`        | ส่วนลดรวม (flash + product)                           |
| `summary.coupon_discount` | คูปอง (`code`, `coupon_name`, `amount`)               |
| `summary.shipping`        | ค่าจัดส่ง                                               |
| `summary.total`           | ยอดชำระทั้งหมด                                          |
| `shipping_address`        | ชื่อผู้รับ, เบอร์, `full_address`, `country`               |
| `items[]`                 | รายการสินค้า (`name`, `image_url`, ราคา, ส่วนลดต่อบรรทัด) |
| `coin_amount_used`        | เมื่อชำระด้วย coin                                       |

---

## Coupons

### Collect Browny Shop coupon

```bash
curl -X POST "{BASE}/coupon/collect-browny-shop" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "code",
    "data": "PROMO2026",
    "customer_id": "{CUSTOMER_ID}"
  }'
```

QR type:

```bash
curl -X POST "{BASE}/coupon/collect-browny-shop" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "qr",
    "data": "https://brownypay.com/coupon/QRREF123",
    "customer_id": "{CUSTOMER_ID}"
  }'
```

### List usable Browny Shop coupons

```bash
curl -X GET "{BASE}/customer/coupons/browny-shop/{CUSTOMER_ID}" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Accept: application/json"
```

---

## Cart APIs (existing)

```bash
# Get cart
curl -X GET "{BASE}/customer/{CUSTOMER_ID}/cart" \
  -H "Authorization: Bearer {TOKEN}"

# Add item
curl -X POST "{BASE}/customer/{CUSTOMER_ID}/cart/items" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{ "product_id": "{PRODUCT_UUID}", "product_sub_id": 1, "quantity": 1 }'
```

---

## Admin settings (web)

| Page                 | URL                                      |
| -------------------- | ---------------------------------------- |
| Default shipping     | `/browny/settings/defaults/shipping-fee` |
| Banners              | `/browny/settings/defaults/banners`      |
| Title image          | `/browny/settings/defaults/title-image`  |
| Discounts (existing) | `/browny-shop/discounts`                 |

---

## Shipping cascade

```
free shipping product → 0
else flash_sale_items.shipping_fee
else product_subs.shipping_fee
else setting_defaults.browny_shop.default_shipping_fee
```

## Coupon rules

- `allow_with_promotion` — allow with flash sale lines
- `allow_with_product_discount` — allow with product sub discount
- Coupon discount applied after line discounts; shipping added before final total (coupon may target product/shipping/both per `discount_target`)
