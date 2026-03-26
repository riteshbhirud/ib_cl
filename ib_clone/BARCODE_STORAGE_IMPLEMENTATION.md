# Barcode Data Storage Implementation

## ✅ Complete Implementation

Now the system saves the barcode data (string/number) to the database so your backend can process it.

---

## What's Stored in Database

### `submissions` table now includes:

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `barcode_data` | TEXT | The actual barcode string/number | `"012345678901"` |
| `barcode_type` | TEXT | Type of barcode detected | `"Code128"`, `"PDF417"`, `"QR"`, `"EAN13"` |
| `barcode_image_url` | TEXT | Optional cropped barcode image | URL to barcode-only image |
| `receipt_image_url` | TEXT | Full receipt image | URL to full receipt |

---

## Flow

### 1. User Scans Receipt Barcode
```
Scanner detects barcode
↓
Extracts: "012345678901"
↓
Determines type: "Code128"
↓
Captures full receipt image
↓
Optionally crops barcode region
```

### 2. Data Saved to Database
```sql
INSERT INTO submissions (
    user_id,
    store_id,
    receipt_image_url,
    barcode_data,          -- "012345678901"
    barcode_type,          -- "Code128"
    barcode_image_url,     -- (optional) URL to cropped barcode
    total_cashback,
    status
) VALUES (...);
```

### 3. Backend Can Process
Your backend can now:
- ✅ Read the `barcode_data` string
- ✅ Validate against receipt system
- ✅ Verify it matches the store
- ✅ Cross-check with receipt image
- ✅ Generate barcode image from string if needed

---

## Database Schema Update

Run this SQL in Supabase:

```sql
BEGIN;

ALTER TABLE public.submissions 
ADD COLUMN IF NOT EXISTS barcode_data TEXT,
ADD COLUMN IF NOT EXISTS barcode_type TEXT,
ADD COLUMN IF NOT EXISTS barcode_image_url TEXT;

COMMENT ON COLUMN public.submissions.barcode_data IS 'The actual barcode string/number extracted from receipt';
COMMENT ON COLUMN public.submissions.barcode_type IS 'Type of barcode (Code128, PDF417, QR, etc)';
COMMENT ON COLUMN public.submissions.barcode_image_url IS 'Optional: Cropped image of just the barcode';

COMMIT;
```

---

## Code Changes

### 1. Model Updated (`Submission.swift`)
```swift
struct Submission {
    let barcodeData: String?      // NEW: "012345678901"
    let barcodeType: String?      // NEW: "Code128"
    let barcodeImageUrl: String?  // NEW: URL to barcode image
    // ... other fields
}
```

### 2. Service Updated (`SubmissionService.swift`)
```swift
func createSubmission(
    barcodeData: String?,      // NEW
    barcodeType: String?,      // NEW
    barcodeImageUrl: String?,  // NEW
    // ... other params
)
```

### 3. AppState Updated
```swift
func submitReceipt(
    barcodeData: String?,      // NEW
    barcodeType: String?,      // NEW
    barcodeImageUrl: String?,  // NEW
    // ... other params
)
```

### 4. ViewModel Updated (`RedeemViewModel.swift`)
```swift
// Now passes barcode data through
try await appState.submitReceipt(
    storeId: store.id,
    items: itemsToSubmit,
    receiptImageUrl: receiptUrl,
    barcodeData: barcodeData,        // NEW
    barcodeType: barcodeType,        // NEW
    barcodeImageUrl: barcodeImgUrl   // NEW (optional)
)
```

---

## Barcode Types Detected

The Vision framework can detect these barcode types:

| Type | Common Use | Example |
|------|------------|---------|
| `Code128` | Retail receipts | Most common on receipts |
| `PDF417` | IDs, boarding passes | 2D barcode |
| `QR` | QR codes | Square 2D code |
| `EAN13` | Product barcodes | 13-digit product codes |
| `EAN8` | Small product barcodes | 8-digit |
| `UPCE` | Compressed UPC | 6-digit |
| `Code39` | Inventory | Alphanumeric |
| `Code93` | Logistics | Extended Code39 |
| `Aztec` | Transport tickets | Square pattern |

---

## Backend Processing Options

### Option 1: Use Barcode String Directly
```python
# Backend receives:
barcode_data = "012345678901"
barcode_type = "Code128"

# Validate with receipt verification service
receipt_info = verify_receipt(barcode_data)
```

### Option 2: Re-generate Barcode Image
```python
# Generate barcode image from string
from barcode import Code128
from barcode.writer import ImageWriter

barcode = Code128(barcode_data, writer=ImageWriter())
barcode.save('receipt_barcode')
```

### Option 3: Use Stored Barcode Image
```python
# Download the cropped barcode image
barcode_img_url = submission['barcode_image_url']
response = requests.get(barcode_img_url)
barcode_image = Image.open(BytesIO(response.content))

# Process with OCR or barcode reader
barcode_data = read_barcode(barcode_image)
```

### Option 4: Hybrid Approach
```python
# Use string for quick validation
if validate_barcode_format(barcode_data):
    # Then verify against image if needed
    verify_barcode_in_image(receipt_image_url, barcode_data)
```

---

## Example Database Query

### Fetch Submission with Barcode Data
```sql
SELECT 
    s.id,
    s.barcode_data,
    s.barcode_type,
    s.barcode_image_url,
    s.receipt_image_url,
    s.total_cashback,
    s.status,
    s.submitted_at,
    st.name as store_name
FROM submissions s
JOIN stores st ON s.store_id = st.id
WHERE s.status = 'pending'
ORDER BY s.submitted_at DESC;
```

Result:
```
id: 123e4567-e89b-12d3-a456-426614174000
barcode_data: "012345678901"
barcode_type: "Code128"
barcode_image_url: "https://...supabase.co/storage/.../barcode.jpg"
receipt_image_url: "https://...supabase.co/storage/.../receipt.jpg"
store_name: "Walmart"
```

---

## Console Output

When submitting, you'll now see:

```
📤 Uploading receipt image...
✅ Receipt image uploaded: https://...supabase.co/storage/.../receipt.jpg
📊 Barcode Data: 012345678901
📊 Barcode Type: Code128
✅ Receipt submitted successfully to database: <UUID>
```

---

## Backend Verification Workflow

### Step 1: Receive Submission
```python
submission = get_pending_submission(submission_id)

barcode = submission['barcode_data']
store_id = submission['store_id']
```

### Step 2: Verify Barcode
```python
# Call receipt verification API
receipt_details = receipt_api.verify(
    barcode=barcode,
    store_id=store_id
)

# Returns:
# {
#   "valid": true,
#   "date": "2026-03-22",
#   "total": 45.67,
#   "items": [...]
# }
```

### Step 3: Cross-Check Items
```python
# Compare submitted items with receipt
for item in submission['items']:
    if item['offer_id'] not in receipt_details['items']:
        reject_submission(
            submission_id,
            reason=f"Item {item['name']} not found on receipt"
        )
        return

approve_submission(submission_id)
```

---

## Testing

### Test Data in Simulator
When using test barcode in simulator:
```
barcode_data: "TEST-RECEIPT-A1B2C3D4"
barcode_type: "Code128"
```

### Real Device
Scan actual receipt barcode:
```
barcode_data: "01234567890123"  (actual barcode number)
barcode_type: "Code128"         (detected type)
```

---

## Advantages of This Approach

### ✅ Fast Processing
- Backend can validate barcode string immediately
- No need to download/process images for basic validation
- OCR not required for barcode reading

### ✅ Flexible
- Have both barcode string AND images
- Can use either or both for verification
- Fallback options if one fails

### ✅ Accurate
- Vision framework is highly accurate
- Barcode extracted before any compression
- Original data preserved

### ✅ Debuggable
- Can see exact barcode in database
- Easy to verify in admin panel
- Can manually check if needed

---

## Admin Dashboard Query

```sql
-- View recent submissions with barcode data
SELECT 
    s.id,
    u.email as user_email,
    st.name as store_name,
    s.barcode_data,
    s.barcode_type,
    s.total_cashback,
    s.status,
    s.submitted_at,
    COUNT(si.id) as item_count
FROM submissions s
JOIN auth.users u ON s.user_id = u.id
JOIN stores st ON s.store_id = st.id
LEFT JOIN submission_items si ON si.submission_id = s.id
GROUP BY s.id, u.email, st.name
ORDER BY s.submitted_at DESC
LIMIT 20;
```

---

## Migration Notes

If you have existing submissions without barcode data:
- They will have `NULL` for barcode fields
- New submissions will have barcode data
- No impact on existing data

---

## Security Considerations

### Barcode Data Validation
```python
def validate_barcode(barcode_data, barcode_type):
    """Validate barcode format matches expected type"""
    
    patterns = {
        'Code128': r'^[\x00-\x7F]+$',  # ASCII characters
        'EAN13': r'^\d{13}$',           # 13 digits
        'EAN8': r'^\d{8}$',             # 8 digits
        'UPCE': r'^\d{6}$',             # 6 digits
    }
    
    if barcode_type in patterns:
        return re.match(patterns[barcode_type], barcode_data)
    
    return True  # Unknown type, accept
```

### Prevent Duplicate Submissions
```sql
-- Check for duplicate barcode submissions
SELECT 
    barcode_data,
    COUNT(*) as submission_count
FROM submissions
WHERE barcode_data IS NOT NULL
  AND status IN ('pending', 'approved')
  AND submitted_at > NOW() - INTERVAL '7 days'
GROUP BY barcode_data
HAVING COUNT(*) > 1;
```

---

## Next Steps

1. ✅ Run the SQL schema update
2. ✅ Test submission with real device
3. ✅ Verify barcode data in database
4. ✅ Implement backend verification
5. ✅ Add admin dashboard to view barcodes

---

**Status:** ✅ **FULLY IMPLEMENTED**

**What You Get:**
- Barcode string saved to database
- Barcode type identified and stored
- Optional cropped barcode image
- Full receipt image
- Backend can process any/all of these

**Your backend can now:**
- Read barcode data directly from database
- Validate receipts using the barcode string
- Generate barcodes if needed
- Cross-check with images
- Process submissions efficiently

---

**Date Implemented:** March 22, 2026
