# Multiple Receipt Images - Implementation Guide

## ✅ Complete Redesign

Receipt submission now supports **multiple photos** for long receipts, with a clean and intuitive UI.

---

## Database Update Required

Run this SQL in Supabase:

```sql
BEGIN;

-- Add column for multiple receipt images
ALTER TABLE public.submissions 
ADD COLUMN IF NOT EXISTS receipt_image_urls TEXT[];

-- Add comment
COMMENT ON COLUMN public.submissions.receipt_image_urls IS 'Array of all receipt image URLs (for long receipts requiring multiple photos)';

-- Remove barcode columns (no longer needed)
ALTER TABLE public.submissions 
DROP COLUMN IF EXISTS barcode_data,
DROP COLUMN IF EXISTS barcode_type,
DROP COLUMN IF EXISTS barcode_image_url;

COMMIT;
```

---

## What Changed

### 1. **Receipt Capture Flow**
**Before:** Barcode scanner → Single photo
**After:** Multiple photo capture → Clear gallery view

### 2. **User Experience**
- ✅ Take photo with camera
- ✅ Choose from photo library
- ✅ Add multiple photos for long receipts
- ✅ Preview all photos before submitting
- ✅ Delete individual photos
- ✅ Reorder photos (coming soon)

### 3. **UI Features**
- Photo counter badge on each image
- Horizontal scrollable gallery
- "Add more" button with dashed border
- Clear instruction banner for long receipts
- Photo count in submit bar

---

## User Flow

### Step 1: Start Receipt Capture
```
User taps "Redeem at [Store]"
↓
Sees requirements popup
↓
Taps "I Understand, Continue"
↓
Photo capture screen opens
```

### Step 2: Capture Photos
```
Empty state shows:
- Large camera icon
- "No Photos Yet" message
- Two buttons:
  • "Take Photo" (camera)
  • "Choose from Library" (photo library)
```

### Step 3: Add More Photos
```
After first photo:
- Shows grid of captured photos
- Each photo has:
  • Index badge (Photo 1, Photo 2, etc.)
  • Delete button (X)
- Info banner: "Long receipt? Add more photos"
- "Add Photo" button (dashed border)
- Bottom bar shows count: "3 photos added"
- "Continue" button
```

### Step 4: Review & Submit
```
Item selection screen shows:
- Scrollable receipt photos at top
- Photo count indicator
- Select items & quantities
- Submit button
```

---

## Database Schema

### `submissions` table structure:

```sql
CREATE TABLE submissions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    store_id UUID NOT NULL,
    receipt_image_url TEXT NOT NULL,        -- First/primary image
    receipt_image_urls TEXT[],              -- All images (NEW!)
    total_cashback NUMERIC NOT NULL,
    status TEXT DEFAULT 'pending',
    submitted_at TIMESTAMP DEFAULT NOW(),
    reviewed_at TIMESTAMP,
    rejection_reason TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### Data Example:

```json
{
  "receipt_image_url": "https://.../receipt_1.jpg",  // Primary
  "receipt_image_urls": [                             // All photos
    "https://.../receipt_1.jpg",
    "https://.../receipt_2.jpg",
    "https://.../receipt_3.jpg"
  ]
}
```

---

## Code Changes

### 1. **New View: ReceiptPhotoCapture**
```swift
Features:
- Camera integration
- Photo library picker
- Image grid layout
- Add/delete functionality
- Photo counter
- Informative UI
```

### 2. **Updated: RedeemViewModel**
```swift
// Before
var selectedImage: UIImage?
var barcodeData: String?
var barcodeType: String?

// After
var receiptImages: [UIImage] = []
```

### 3. **Updated: SubmissionService**
```swift
// Before
func createSubmission(receiptUrl: String, ...)

// After
func createSubmission(receiptUrls: [String], ...)
```

### 4. **Updated: AppState**
```swift
// Before
func submitReceipt(receiptImageUrl: String, ...)

// After
func submitReceipt(receiptImageUrls: [String], ...)
```

---

## UI/UX Improvements

### Empty State
- Clear icon and messaging
- Two action buttons for flexibility
- Professional, modern design

### Photo Grid
- 2-column grid layout
- Each photo shows clearly
- Index badges for order
- Easy delete with X button
- Dashed "Add Photo" button stands out

### Info Banner
- Helpful tip about long receipts
- Doesn't obstruct workflow
- Icon + clear message

### Bottom Bar
- Shows photo count
- Prominent "Continue" button
- Shadow for elevation

### Item Selection
- Horizontal scrollable receipt gallery
- Doesn't take up too much space
- Easy to reference while selecting items

---

## Backend Processing

### Retrieve Submission with Images

```python
# Get submission
submission = db.query("""
    SELECT 
        id,
        receipt_image_url,
        receipt_image_urls,
        total_cashback,
        status
    FROM submissions
    WHERE id = %s
""", (submission_id,))

# Access images
primary_image = submission['receipt_image_url']
all_images = submission['receipt_image_urls']  # Array

print(f"Number of receipt photos: {len(all_images)}")

# Download and process all images
for i, image_url in enumerate(all_images):
    print(f"Processing image {i + 1}/{len(all_images)}")
    image_data = download_image(image_url)
    # OCR, verification, etc.
```

### Combine Images for Review

```python
from PIL import Image

def combine_receipt_images(image_urls):
    """Combine multiple receipt photos into one tall image"""
    images = [download_and_open(url) for url in image_urls]
    
    # Calculate total height
    total_height = sum(img.height for img in images)
    max_width = max(img.width for img in images)
    
    # Create combined image
    combined = Image.new('RGB', (max_width, total_height))
    
    # Paste images vertically
    y_offset = 0
    for img in images:
        combined.paste(img, (0, y_offset))
        y_offset += img.height
    
    return combined

# Usage
combined_receipt = combine_receipt_images(submission['receipt_image_urls'])
combined_receipt.save('full_receipt.jpg')
```

### OCR Processing

```python
from google.cloud import vision

def process_multi_image_receipt(image_urls):
    """Process all receipt images with OCR"""
    client = vision.ImageAnnotatorClient()
    all_text = []
    
    for i, url in enumerate(image_urls):
        print(f"OCR on image {i + 1}/{len(image_urls)}")
        
        image = vision.Image()
        image.source.image_uri = url
        
        response = client.text_detection(image=image)
        texts = response.text_annotations
        
        if texts:
            all_text.append(texts[0].description)
    
    # Combine all text
    full_receipt_text = '\n--- Next Photo ---\n'.join(all_text)
    
    return full_receipt_text
```

---

## Admin Dashboard View

### Display Multiple Images

```html
<div class="receipt-images">
    <h3>Receipt Photos ({{ count }})</h3>
    
    <div class="image-grid">
        {% for url in submission.receipt_image_urls %}
        <div class="receipt-photo">
            <span class="photo-badge">Photo {{ loop.index }}</span>
            <img src="{{ url }}" alt="Receipt {{ loop.index }}">
            <a href="{{ url }}" target="_blank">View Full Size</a>
        </div>
        {% endfor %}
    </div>
    
    <button onclick="downloadAllImages()">Download All</button>
    <button onclick="showCombinedView()">View Combined</button>
</div>
```

---

## Benefits

### For Users
✅ No struggling with long receipts
✅ Clear photos of all items
✅ Easy to add/remove photos
✅ Visual confirmation before submit
✅ Flexible capture options (camera or library)

### For Reviewers
✅ Complete receipt visibility
✅ All items clearly readable
✅ Can see full context
✅ Better verification accuracy
✅ Fewer rejections due to incomplete receipts

### For System
✅ Higher approval rates
✅ Fewer disputes
✅ Better data quality
✅ Easier automated processing
✅ More user satisfaction

---

## Testing Checklist

- [ ] Can take photo with camera
- [ ] Can choose from photo library
- [ ] Can add multiple photos
- [ ] Can delete individual photos
- [ ] Photos show in correct order
- [ ] Counter updates correctly
- [ ] All photos upload successfully
- [ ] Database stores all URLs
- [ ] Item selection shows photos
- [ ] Success screen displays
- [ ] Submission appears in activity
- [ ] Admin can view all images

---

## Migration Notes

### Existing Submissions
- Old submissions have only `receipt_image_url`
- `receipt_image_urls` will be `NULL`
- Backend should handle both cases:

```python
# Handle old and new format
if submission['receipt_image_urls']:
    images = submission['receipt_image_urls']  # New format
else:
    images = [submission['receipt_image_url']]  # Old format
```

### Gradual Rollout
```sql
-- Check adoption rate
SELECT 
    COUNT(*) FILTER (WHERE receipt_image_urls IS NOT NULL AND array_length(receipt_image_urls, 1) > 1) as multi_photo,
    COUNT(*) FILTER (WHERE receipt_image_urls IS NULL OR array_length(receipt_image_urls, 1) = 1) as single_photo,
    COUNT(*) as total
FROM submissions
WHERE submitted_at > NOW() - INTERVAL '7 days';
```

---

## Future Enhancements

### Coming Soon:
- [ ] Drag to reorder photos
- [ ] Crop individual images
- [ ] Auto-rotate photos
- [ ] Compress before upload
- [ ] Progress indicator for uploads
- [ ] Retry failed uploads
- [ ] Photo editing tools
- [ ] AI-suggested crop areas

---

**Status:** ✅ **Ready to Deploy**

**Date:** March 22, 2026

**Summary:** Receipt submission now supports multiple photos with an intuitive UI, making it easy for users to capture complete receipts regardless of length.

---

## Quick Setup

1. **Run SQL** to add `receipt_image_urls` column
2. **Clean & rebuild** the app
3. **Test** on device (camera required)
4. **Verify** images appear in Supabase Storage
5. **Check** database for image URLs array

Done! 🎉
