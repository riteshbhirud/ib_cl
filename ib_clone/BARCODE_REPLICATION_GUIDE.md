# Barcode Replication - Complete Guide

## Issue: Barcode Not Matching on Backend

When you scan an EAN13 barcode and try to regenerate it on the backend, it doesn't match the original.

### Common Causes:

1. **Missing Check Digit** - EAN13 requires exactly 13 digits, last one is calculated
2. **Incomplete Data** - `payloadStringValue` sometimes returns partial data
3. **Format Differences** - Barcode libraries expect specific formats

---

## ✅ Solution Implemented

### Updated Barcode Scanner to:

1. **Extract complete data** including check digit
2. **Validate EAN13 format** (must be 13 digits)
3. **Calculate check digit** if missing
4. **Log detailed info** for debugging

---

## How EAN13 Barcodes Work

### Structure:
```
[Country][Manufacturer][Product][Check]
   3         4-5         3-4       1
   
Example: 0123456789012
         ↑           ↑
      12 digits   check digit
```

### Check Digit Calculation:
1. Take first 12 digits
2. Multiply alternating digits by 1 and 3
3. Sum all results
4. Subtract from next multiple of 10

**Example:**
```
Code: 012345678901?

Position: 1  2  3  4  5  6  7  8  9  10 11 12
Digit:    0  1  2  3  4  5  6  7  8  9  0  1
Multiply: ×1 ×3 ×1 ×3 ×1 ×3 ×1 ×3 ×1 ×3 ×1 ×3
Result:   0  3  2  9  4  15 6  21 8  27 0  3

Sum: 0+3+2+9+4+15+6+21+8+27+0+3 = 98
Next 10: 100
Check: 100 - 98 = 2

Final: 0123456789012
```

---

## Testing the Scanner

### 1. Console Output

When you scan a barcode, you should now see:

```
🔍 Scanned Barcode:
   Data: 0123456789012
   Type: EAN13
   Length: 13
📊 Barcode Data: 0123456789012
📊 Barcode Type: EAN13
```

### 2. Database Entry

Check your Supabase `submissions` table:

```sql
SELECT 
    barcode_data,
    barcode_type,
    length(barcode_data) as barcode_length
FROM submissions
ORDER BY submitted_at DESC
LIMIT 1;
```

Expected:
```
barcode_data: "0123456789012"
barcode_type: "EAN13"
barcode_length: 13
```

---

## Backend Barcode Generation

### Python Example:

```python
from barcode import EAN13
from barcode.writer import ImageWriter

# Get barcode data from database
submission = get_submission(submission_id)
barcode_data = submission['barcode_data']  # "0123456789012"
barcode_type = submission['barcode_type']  # "EAN13"

# Generate barcode image
if barcode_type == "EAN13":
    # EAN13 class expects 12 digits, calculates 13th automatically
    # So we pass first 12 digits
    if len(barcode_data) == 13:
        code = barcode_data[:12]
    else:
        code = barcode_data
    
    ean = EAN13(code, writer=ImageWriter())
    filename = ean.save(f'barcode_{submission_id}')
    
elif barcode_type == "Code128":
    from barcode import Code128
    code128 = Code128(barcode_data, writer=ImageWriter())
    filename = code128.save(f'barcode_{submission_id}')
```

### Node.js Example:

```javascript
const bwipjs = require('bwip-js');

// Get from database
const barcodeData = submission.barcode_data;  // "0123456789012"
const barcodeType = submission.barcode_type;  // "EAN13"

// Map types
const typeMap = {
    'EAN13': 'ean13',
    'Code128': 'code128',
    'PDF417': 'pdf417',
    'QR': 'qrcode'
};

// Generate barcode
bwipjs.toBuffer({
    bcid: typeMap[barcodeType] || 'code128',
    text: barcodeData,
    scale: 3,
    height: 10,
    includetext: true
}, (err, png) => {
    if (err) {
        console.error(err);
    } else {
        // Save or use png buffer
        fs.writeFileSync(`barcode_${submissionId}.png`, png);
    }
});
```

### PHP Example:

```php
require 'vendor/autoload.php';
use Picqer\Barcode\BarcodeGeneratorPNG;

$submission = getSubmission($submissionId);
$barcodeData = $submission['barcode_data'];  // "0123456789012"
$barcodeType = $submission['barcode_type'];  // "EAN13"

$generator = new BarcodeGeneratorPNG();

$typeMap = [
    'EAN13' => $generator::TYPE_EAN_13,
    'Code128' => $generator::TYPE_CODE_128,
    'QR' => $generator::TYPE_QRCODE,
];

$barcode = $generator->getBarcode(
    $barcodeData, 
    $typeMap[$barcodeType] ?? $generator::TYPE_CODE_128
);

file_put_contents("barcode_{$submissionId}.png", $barcode);
```

---

## Troubleshooting

### Issue: Generated barcode still doesn't match

**Check 1: Verify data length**
```sql
SELECT 
    barcode_data,
    barcode_type,
    length(barcode_data) as len,
    length(trim(barcode_data)) as trimmed_len
FROM submissions 
WHERE id = 'YOUR_SUBMISSION_ID';
```

**Check 2: Verify it's all digits (for EAN13)**
```python
barcode_data = "0123456789012"
is_valid = barcode_data.isdigit() and len(barcode_data) == 13
print(f"Valid EAN13: {is_valid}")
```

**Check 3: Compare check digits**
```python
def calculate_ean13_check(code):
    """Calculate EAN13 check digit"""
    if len(code) not in [12, 13]:
        return None
    
    # Use first 12 digits
    digits = code[:12]
    
    # Calculate sum
    sum_val = 0
    for i, digit in enumerate(digits):
        multiplier = 1 if i % 2 == 0 else 3
        sum_val += int(digit) * multiplier
    
    # Calculate check digit
    check = (10 - (sum_val % 10)) % 10
    return str(check)

# From database
scanned_code = "0123456789012"
scanned_check = scanned_code[12]
calculated_check = calculate_ean13_check(scanned_code)

print(f"Scanned check digit: {scanned_check}")
print(f"Calculated check digit: {calculated_check}")
print(f"Match: {scanned_check == calculated_check}")
```

**Check 4: Try without check digit**
```python
# Some libraries auto-calculate check digit
# Try passing only first 12 digits
barcode_data_full = "0123456789012"  # 13 digits from DB
barcode_data_12 = barcode_data_full[:12]  # First 12 only

# Try both
ean_from_13 = EAN13(barcode_data_full[:12])
ean_from_12 = EAN13(barcode_data_12)
```

---

## Validation on Backend

### Before generating barcode, validate:

```python
def validate_barcode_data(barcode_data, barcode_type):
    """Validate barcode data before generation"""
    
    if barcode_type == "EAN13":
        # Must be 13 digits
        if not barcode_data.isdigit():
            return False, "EAN13 must contain only digits"
        
        if len(barcode_data) != 13:
            return False, f"EAN13 must be 13 digits, got {len(barcode_data)}"
        
        # Verify check digit
        calculated = calculate_ean13_check(barcode_data)
        actual = barcode_data[12]
        
        if calculated != actual:
            return False, f"Invalid check digit. Expected {calculated}, got {actual}"
        
        return True, "Valid EAN13"
    
    elif barcode_type == "EAN8":
        if not barcode_data.isdigit() or len(barcode_data) != 8:
            return False, "EAN8 must be 8 digits"
        return True, "Valid EAN8"
    
    elif barcode_type == "Code128":
        # Code128 is more flexible
        if len(barcode_data) == 0:
            return False, "Code128 cannot be empty"
        return True, "Valid Code128"
    
    elif barcode_type == "QR":
        # QR codes can contain anything
        return True, "Valid QR"
    
    else:
        return True, f"Unknown type {barcode_type}, assuming valid"

# Usage
valid, message = validate_barcode_data(submission['barcode_data'], submission['barcode_type'])
if not valid:
    print(f"Invalid barcode: {message}")
    # Reject submission or flag for manual review
```

---

## Visual Comparison

### Option 1: Generate and Compare Images

```python
from PIL import Image, ImageChops
import numpy as np

# Generate barcode from scanned data
generated_img = generate_barcode(barcode_data, barcode_type)

# Download original receipt image
original_img = download_image(submission['receipt_image_url'])

# Crop barcode region from original (if you know coordinates)
# Or use barcode detection to find it
cropped_barcode = detect_and_crop_barcode(original_img)

# Compare
def images_are_similar(img1, img2, threshold=0.95):
    """Compare two images for similarity"""
    diff = ImageChops.difference(img1, img2)
    diff_array = np.array(diff)
    similarity = 1 - (np.sum(diff_array) / (diff_array.size * 255))
    return similarity > threshold

similar = images_are_similar(generated_img, cropped_barcode)
print(f"Barcodes match: {similar}")
```

### Option 2: Re-scan Generated Barcode

```python
from pyzbar.pyzbar import decode
from PIL import Image

# Generate barcode image
generated_img = generate_barcode(barcode_data, barcode_type)

# Scan the generated image
detected = decode(Image.open(generated_img))

if detected:
    regenerated_data = detected[0].data.decode('utf-8')
    original_data = barcode_data
    
    print(f"Original:     {original_data}")
    print(f"Regenerated:  {regenerated_data}")
    print(f"Match: {original_data == regenerated_data}")
else:
    print("Could not decode generated barcode")
```

---

## Advanced: Store Additional Metadata

Update your database to store more barcode information:

```sql
ALTER TABLE submissions
ADD COLUMN barcode_raw_data BYTEA,  -- Raw binary data
ADD COLUMN barcode_format_version TEXT,  -- EAN13, EAN13+2, etc
ADD COLUMN barcode_country_code TEXT,  -- First 3 digits for EAN
ADD COLUMN barcode_validation_passed BOOLEAN DEFAULT true;
```

Then in your Swift code:

```swift
// After scanning
if barcodeType == "EAN13" && barcodeData.count == 13 {
    let countryCode = String(barcodeData.prefix(3))
    // Store country code for validation
}
```

---

## Common EAN13 Country Codes

| Code | Country/Region |
|------|----------------|
| 000-019 | USA & Canada |
| 020-029 | In-store codes |
| 030-039 | USA drugs |
| 040-049 | Reserved |
| 050-059 | Coupons |
| 060-099 | USA & Canada |
| 100-139 | USA |
| 200-299 | In-store codes |
| 300-379 | France |
| 380 | Bulgaria |
| 383 | Slovenia |
| 400-440 | Germany |
| 450-459 | Japan |
| 460-469 | Russia |
| 470 | Kyrgyzstan |
| 471 | Taiwan |
| 474 | Estonia |
| 475 | Latvia |
| 476 | Azerbaijan |
| 477 | Lithuania |
| 478 | Uzbekistan |
| 479 | Sri Lanka |
| 480 | Philippines |
| 481 | Belarus |
| 482 | Ukraine |
| 484 | Moldova |
| 485 | Armenia |
| 486 | Georgia |
| 487 | Kazakhstan |
| 489 | Hong Kong |
| 490-499 | Japan |
| 500-509 | UK |
| 520-521 | Greece |
| 528 | Lebanon |
| 529 | Cyprus |
| 530 | Albania |
| 531 | Macedonia |
| 535 | Malta |
| 539 | Ireland |
| 540-549 | Belgium & Luxembourg |
| 560 | Portugal |
| 569 | Iceland |
| 570-579 | Denmark |
| 590 | Poland |
| 594 | Romania |
| 599 | Hungary |
| 600-601 | South Africa |
| 603 | Ghana |
| 608 | Bahrain |
| 609 | Mauritius |
| 611 | Morocco |
| 613 | Algeria |
| 615 | Nigeria |
| 616 | Kenya |
| 618 | Ivory Coast |
| 619 | Tunisia |
| 621 | Syria |
| 622 | Egypt |
| 624 | Libya |
| 625 | Jordan |
| 626 | Iran |
| 627 | Kuwait |
| 628 | Saudi Arabia |
| 629 | Emirates |
| 640-649 | Finland |
| 690-699 | China |
| 700-709 | Norway |
| 729 | Israel |
| 730-739 | Sweden |
| 740 | Guatemala |
| 741 | El Salvador |
| 742 | Honduras |
| 743 | Nicaragua |
| 744 | Costa Rica |
| 745 | Panama |
| 746 | Dominican Republic |
| 750 | Mexico |
| 754-755 | Canada |
| 759 | Venezuela |
| 760-769 | Switzerland |
| 770-771 | Colombia |
| 773 | Uruguay |
| 775 | Peru |
| 777 | Bolivia |
| 779 | Argentina |
| 780 | Chile |
| 784 | Paraguay |
| 786 | Ecuador |
| 789-790 | Brazil |
| 800-839 | Italy |
| 840-849 | Spain |
| 850 | Cuba |
| 858 | Slovakia |
| 859 | Czech Republic |
| 860 | Serbia |
| 865 | Mongolia |
| 867 | North Korea |
| 868-869 | Turkey |
| 870-879 | Netherlands |
| 880 | South Korea |
| 884 | Cambodia |
| 885 | Thailand |
| 888 | Singapore |
| 890 | India |
| 893 | Vietnam |
| 896 | Pakistan |
| 899 | Indonesia |
| 900-919 | Austria |
| 930-939 | Australia |
| 940-949 | New Zealand |
| 950 | GS1 Global Office |
| 951 | EAN (old) |
| 955 | Malaysia |
| 958 | Macau |
| 960-969 | UK (old) |
| 977 | Periodicals (ISSN) |
| 978-979 | Books (ISBN) |
| 980 | Refund receipts |
| 981-984 | Coupons |
| 990-999 | Coupons |

---

## Summary

### What We Fixed:
1. ✅ Extract complete barcode data including check digit
2. ✅ Validate EAN13 is exactly 13 digits
3. ✅ Calculate check digit if missing
4. ✅ Log barcode data, type, and length for debugging

### What Your Backend Should Do:
1. ✅ Validate barcode format before generation
2. ✅ Use correct library for each barcode type
3. ✅ For EAN13: Pass first 12 digits (library calculates 13th)
4. ✅ Compare regenerated barcode with original data

### Testing:
```bash
# When you scan, check console:
🔍 Scanned Barcode:
   Data: 0123456789012
   Type: EAN13
   Length: 13

# Then in database:
barcode_data: "0123456789012"  (13 chars)
barcode_type: "EAN13"

# Backend generation:
code_12_digits = barcode_data[:12]  # "012345678901"
ean = EAN13(code_12_digits)  # Generates with check digit
# Result: 0123456789012 ✅
```

---

**Status:** ✅ **Ready to Test**

Test with a real receipt and verify the barcode data in your console and database!
