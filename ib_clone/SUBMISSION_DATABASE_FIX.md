# Receipt Submission Database Fix

## Issue Found ❌

**Problem:** Submissions showed in the app's Activity tab but were not being saved to the Supabase database.

**Root Cause:** The `AppState.submitReceipt()` function was only:
- Creating a local submission object
- Adding it to the local `submissions` array
- Using a simulated delay instead of actual API calls

It was **NOT** calling the `SubmissionService` to save data to Supabase!

---

## What Was Fixed ✅

### 1. **AppState.swift - submitReceipt() Function**

**Before:**
```swift
// ❌ Only simulated the submission
func submitReceipt(...) async throws {
    // Create local submission object
    let submission = Submission(...)
    
    // Fake API delay
    try await Task.sleep(nanoseconds: 500_000_000)
    
    // Only added to local array
    submissions.insert(submission, at: 0)
}
```

**After:**
```swift
// ✅ Actually saves to database
func submitReceipt(...) async throws {
    // Prepare data for API
    let submissionItemsInput = items.map { ... }
    
    // 🔥 CALL THE SUBMISSION SERVICE
    let submittedSubmission = try await SubmissionService().createSubmission(
        userId: userId,
        storeId: storeId,
        receiptUrl: receiptImageUrl,
        items: submissionItemsInput,
        totalCashback: totalCashback
    )
    
    // Update local state with database result
    submissions.insert(submittedSubmission, at: 0)
}
```

### 2. **RedeemViewModel.swift - Image Upload**

**Before:**
```swift
// ❌ Used a mock URL
let mockImageUrl = "receipt_\(UUID().uuidString)"

try await appState.submitReceipt(
    storeId: store.id,
    items: itemsToSubmit,
    receiptImageUrl: mockImageUrl
)
```

**After:**
```swift
// ✅ Actually uploads image to Supabase Storage
let imageData = image.jpegData(compressionQuality: 0.8) ?? Data()
let submissionService = SubmissionService()

// Upload to storage bucket
let receiptUrl = try await submissionService.uploadReceiptImage(
    userId: userId,
    imageData: imageData
)

// Use real URL from storage
try await appState.submitReceipt(
    storeId: store.id,
    items: itemsToSubmit,
    receiptImageUrl: receiptUrl
)
```

---

## What Happens Now ✅

### Complete Submission Flow:

1. **User scans receipt** → Image captured
2. **User selects items** → Items and quantities selected
3. **User taps "Submit for Review"** → Submission starts

4. **📤 Image Upload** (NEW!)
   - Receipt image compressed to JPEG (80% quality)
   - Uploaded to Supabase Storage bucket: `receipts`
   - Stored at path: `{userId}/{uuid}.jpg`
   - Signed URL generated (valid for 1 year)

5. **💾 Database Save** (NEW!)
   - **submissions** table: Main submission record created
   - **submission_items** table: All items saved
   - **user_offer_lists** table: Items removed from user's list
   - Returns the created submission with auto-generated ID

6. **📱 Local State Update**
   - App state updated with database submission
   - Activity view refreshed automatically
   - Success screen shown

7. **✅ Success!**
   - Haptic feedback triggered
   - User sees confirmation
   - Data persisted in database

---

## Database Tables Affected

### `submissions` table
```sql
INSERT INTO submissions (
    id,                    -- Auto-generated UUID
    user_id,              -- Current user
    store_id,             -- Store where receipt is from
    receipt_image_url,    -- Signed URL from storage
    total_cashback,       -- Sum of all items
    status,               -- Default: 'pending'
    submitted_at          -- Default: now()
)
```

### `submission_items` table
```sql
INSERT INTO submission_items (
    id,                    -- Auto-generated UUID
    submission_id,        -- Link to parent submission
    offer_id,             -- Offer being redeemed
    offer_name,           -- Cached offer name
    quantity,             -- Number purchased
    cashback_per_item,    -- Cashback amount per item
    total_cashback        -- quantity × cashback_per_item
)
-- One row per selected item
```

### `user_offer_lists` table
```sql
DELETE FROM user_offer_lists
WHERE user_id = ? 
  AND offer_id IN (...)
-- Removes submitted items from list
```

---

## Storage Bucket Structure

```
receipts/
├── {user_id_1}/
│   ├── {uuid_1}.jpg
│   ├── {uuid_2}.jpg
│   └── ...
├── {user_id_2}/
│   ├── {uuid_3}.jpg
│   └── ...
└── ...
```

Each receipt image:
- Organized by user ID
- Unique filename (UUID)
- JPEG format (80% compression)
- Accessible via signed URL

---

## Error Handling

The updated code now properly handles:

1. **Authentication Errors**
   ```swift
   guard let userId = currentUser?.id else {
       throw NSError(..., "User not authenticated")
   }
   ```

2. **Image Upload Failures**
   - Network errors
   - Storage bucket permission issues
   - File format problems

3. **Database Insert Failures**
   - Constraint violations
   - Network timeouts
   - Invalid data

4. **Detailed Error Messages**
   ```swift
   print("❌ Submission error: \(error)")
   submissionError = error.localizedDescription
   ```

---

## Testing Checklist

### Before Testing:
- [ ] Supabase Storage bucket `receipts` exists
- [ ] Storage bucket has correct RLS policies
- [ ] Database tables have correct structure
- [ ] User is authenticated

### Test the Flow:
1. [ ] Add offers to list
2. [ ] Start redeem flow
3. [ ] Scan receipt (real device) or use test barcode (simulator)
4. [ ] Select items and quantities
5. [ ] Submit for review
6. [ ] Check console for upload messages
7. [ ] Verify success screen appears
8. [ ] **Check Supabase Dashboard:**
   - [ ] `submissions` table has new row
   - [ ] `submission_items` table has item rows
   - [ ] `receipts` storage bucket has image file
   - [ ] `user_offer_lists` items removed
9. [ ] Check Activity tab shows submission
10. [ ] Check submission detail view

---

## Console Output

You should now see these logs:

```
📤 Uploading receipt image...
✅ Receipt image uploaded: https://...supabase.co/storage/v1/object/sign/receipts/...
✅ Receipt submitted successfully to database: <UUID>
```

If you see errors, check:
- Supabase project URL and anon key
- Storage bucket policies
- Database RLS policies
- Network connection

---

## Supabase Storage Policies Required

Make sure your `receipts` bucket has these policies:

### Upload Policy (for authenticated users):
```sql
CREATE POLICY "Users can upload their own receipts"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'receipts' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);
```

### Read Policy (for authenticated users):
```sql
CREATE POLICY "Users can read their own receipts"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'receipts' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);
```

### Admin Read Policy (optional - for review process):
```sql
CREATE POLICY "Admins can read all receipts"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'receipts'
    -- Add your admin check here
);
```

---

## Comparison: Before vs After

| Aspect | Before ❌ | After ✅ |
|--------|----------|----------|
| **Database Save** | No | Yes |
| **Image Upload** | Mock URL | Real Supabase Storage |
| **Item Removal** | Local only | Database + Local |
| **Error Handling** | Basic | Comprehensive |
| **Console Logging** | Minimal | Detailed |
| **Data Persistence** | Session only | Permanent |
| **Admin Dashboard** | Empty | Shows all data |

---

## Next Steps

1. **Test the submission flow** end-to-end
2. **Verify database entries** in Supabase Dashboard
3. **Check storage bucket** for uploaded images
4. **Test error scenarios:**
   - Network offline
   - Invalid image
   - Database errors
5. **Review RLS policies** to ensure security

---

## Notes

- Images are compressed to 80% quality to reduce storage size
- Signed URLs expire after 1 year (31,536,000 seconds)
- Submission IDs are auto-generated by the database
- Items are automatically removed from user's list after submission
- Status defaults to `pending` in the database

---

**Fixed:** March 22, 2026
**Files Modified:**
- `AppAppState.swift`
- `FeaturesRedeemViewModelsRedeemViewModel.swift`
