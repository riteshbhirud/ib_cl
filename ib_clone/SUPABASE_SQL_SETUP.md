# Complete SQL Setup for Receipt Submissions

Run these SQL commands in your Supabase SQL Editor to set up the complete database structure.

---

## 1. Create Storage Bucket for Receipts

```sql
-- Create the receipts storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('receipts', 'receipts', false);
```

---

## 2. Create Database Tables

### submissions table
```sql
-- Create submissions table
CREATE TABLE IF NOT EXISTS public.submissions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
    receipt_image_url TEXT NOT NULL,
    total_cashback DECIMAL(10, 2) NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_submissions_user_id ON public.submissions(user_id);
CREATE INDEX IF NOT EXISTS idx_submissions_store_id ON public.submissions(store_id);
CREATE INDEX IF NOT EXISTS idx_submissions_status ON public.submissions(status);
CREATE INDEX IF NOT EXISTS idx_submissions_submitted_at ON public.submissions(submitted_at DESC);

-- Add comment
COMMENT ON TABLE public.submissions IS 'Stores receipt submissions from users for cashback redemption';
```

### submission_items table
```sql
-- Create submission_items table
CREATE TABLE IF NOT EXISTS public.submission_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    submission_id UUID NOT NULL REFERENCES public.submissions(id) ON DELETE CASCADE,
    offer_id UUID NOT NULL REFERENCES public.offers(id) ON DELETE CASCADE,
    offer_name TEXT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    cashback_per_item DECIMAL(10, 2) NOT NULL DEFAULT 0,
    total_cashback DECIMAL(10, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_submission_items_submission_id ON public.submission_items(submission_id);
CREATE INDEX IF NOT EXISTS idx_submission_items_offer_id ON public.submission_items(offer_id);

-- Add comment
COMMENT ON TABLE public.submission_items IS 'Individual items within a receipt submission';
```

---

## 3. Enable Row Level Security (RLS)

```sql
-- Enable RLS on submissions table
ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;

-- Enable RLS on submission_items table
ALTER TABLE public.submission_items ENABLE ROW LEVEL SECURITY;
```

---

## 4. Create RLS Policies for Submissions

### Submissions Table Policies

```sql
-- Policy: Users can insert their own submissions
CREATE POLICY "Users can insert their own submissions"
ON public.submissions
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can view their own submissions
CREATE POLICY "Users can view their own submissions"
ON public.submissions
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Policy: Users can update their own pending submissions
CREATE POLICY "Users can update their own pending submissions"
ON public.submissions
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id AND status = 'pending')
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own pending submissions
CREATE POLICY "Users can delete their own pending submissions"
ON public.submissions
FOR DELETE
TO authenticated
USING (auth.uid() = user_id AND status = 'pending');

-- Optional: Admin policy to view all submissions
-- Uncomment and modify if you have an admin role system
-- CREATE POLICY "Admins can view all submissions"
-- ON public.submissions
-- FOR SELECT
-- TO authenticated
-- USING (
--     EXISTS (
--         SELECT 1 FROM public.user_profiles
--         WHERE id = auth.uid() AND role = 'admin'
--     )
-- );
```

---

## 5. Create RLS Policies for Submission Items

```sql
-- Policy: Users can insert items for their own submissions
CREATE POLICY "Users can insert items for their own submissions"
ON public.submission_items
FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.submissions
        WHERE id = submission_id AND user_id = auth.uid()
    )
);

-- Policy: Users can view items for their own submissions
CREATE POLICY "Users can view items for their own submissions"
ON public.submission_items
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.submissions
        WHERE id = submission_id AND user_id = auth.uid()
    )
);

-- Policy: Users can update items for their own pending submissions
CREATE POLICY "Users can update items for their own pending submissions"
ON public.submission_items
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.submissions
        WHERE id = submission_id 
        AND user_id = auth.uid() 
        AND status = 'pending'
    )
);

-- Policy: Users can delete items from their own pending submissions
CREATE POLICY "Users can delete items from their own pending submissions"
ON public.submission_items
FOR DELETE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.submissions
        WHERE id = submission_id 
        AND user_id = auth.uid() 
        AND status = 'pending'
    )
);
```

---

## 6. Storage Bucket Policies

```sql
-- Policy: Users can upload receipts to their own folder
CREATE POLICY "Users can upload their own receipts"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'receipts' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy: Users can view their own receipts
CREATE POLICY "Users can read their own receipts"
ON storage.objects
FOR SELECT
TO authenticated
USING (
    bucket_id = 'receipts' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy: Users can update their own receipts
CREATE POLICY "Users can update their own receipts"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
    bucket_id = 'receipts' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy: Users can delete their own receipts
CREATE POLICY "Users can delete their own receipts"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'receipts' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Optional: Admin policy to view all receipts
-- Uncomment if you need admins to review receipt images
-- CREATE POLICY "Admins can read all receipts"
-- ON storage.objects
-- FOR SELECT
-- TO authenticated
-- USING (
--     bucket_id = 'receipts'
--     AND EXISTS (
--         SELECT 1 FROM public.user_profiles
--         WHERE id = auth.uid() AND role = 'admin'
--     )
-- );
```

---

## 7. Create Automatic Updated_At Trigger

```sql
-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for submissions table
DROP TRIGGER IF EXISTS set_updated_at ON public.submissions;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.submissions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
```

---

## 8. Create Helper Functions (Optional but Recommended)

### Function: Get submission statistics for a user
```sql
-- Function to get submission stats for a user
CREATE OR REPLACE FUNCTION public.get_user_submission_stats(p_user_id UUID)
RETURNS TABLE(
    total_submissions BIGINT,
    pending_submissions BIGINT,
    approved_submissions BIGINT,
    rejected_submissions BIGINT,
    total_cashback_earned DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) AS total_submissions,
        COUNT(*) FILTER (WHERE status = 'pending') AS pending_submissions,
        COUNT(*) FILTER (WHERE status = 'approved') AS approved_submissions,
        COUNT(*) FILTER (WHERE status = 'rejected') AS rejected_submissions,
        COALESCE(SUM(total_cashback) FILTER (WHERE status = 'approved'), 0) AS total_cashback_earned
    FROM public.submissions
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.get_user_submission_stats(UUID) TO authenticated;
```

### Function: Approve a submission
```sql
-- Function to approve a submission (admin only)
CREATE OR REPLACE FUNCTION public.approve_submission(
    p_submission_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    v_total_cashback DECIMAL;
    v_user_id UUID;
BEGIN
    -- Get submission details
    SELECT total_cashback, user_id
    INTO v_total_cashback, v_user_id
    FROM public.submissions
    WHERE id = p_submission_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Submission not found';
    END IF;
    
    -- Update submission status
    UPDATE public.submissions
    SET 
        status = 'approved',
        reviewed_at = NOW()
    WHERE id = p_submission_id;
    
    -- Update user balance (assuming you have a user_profiles table with balance)
    -- Uncomment if you have this structure
    -- UPDATE public.user_profiles
    -- SET balance = balance + v_total_cashback
    -- WHERE id = v_user_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Function: Reject a submission
```sql
-- Function to reject a submission (admin only)
CREATE OR REPLACE FUNCTION public.reject_submission(
    p_submission_id UUID,
    p_reason TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE public.submissions
    SET 
        status = 'rejected',
        reviewed_at = NOW(),
        rejection_reason = p_reason
    WHERE id = p_submission_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Submission not found';
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 9. Verify Setup

```sql
-- Check if tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('submissions', 'submission_items');

-- Check if storage bucket exists
SELECT * FROM storage.buckets WHERE id = 'receipts';

-- Check RLS policies
SELECT tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('submissions', 'submission_items');

-- Check storage policies
SELECT *
FROM pg_policies
WHERE schemaname = 'storage'
AND tablename = 'objects'
AND policyname LIKE '%receipt%';
```

---

## 10. Grant Permissions

```sql
-- Grant permissions on tables
GRANT ALL ON public.submissions TO authenticated;
GRANT ALL ON public.submission_items TO authenticated;

-- Grant usage on sequences
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
```

---

## Quick Setup Script (Run All at Once)

If you want to run everything at once, copy this entire block:

```sql
-- ==================================
-- COMPLETE SUBMISSIONS SETUP SCRIPT
-- ==================================

BEGIN;

-- 1. Create storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('receipts', 'receipts', false)
ON CONFLICT (id) DO NOTHING;

-- 2. Create submissions table
CREATE TABLE IF NOT EXISTS public.submissions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
    receipt_image_url TEXT NOT NULL,
    total_cashback DECIMAL(10, 2) NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create submission_items table
CREATE TABLE IF NOT EXISTS public.submission_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    submission_id UUID NOT NULL REFERENCES public.submissions(id) ON DELETE CASCADE,
    offer_id UUID NOT NULL REFERENCES public.offers(id) ON DELETE CASCADE,
    offer_name TEXT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    cashback_per_item DECIMAL(10, 2) NOT NULL DEFAULT 0,
    total_cashback DECIMAL(10, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Create indexes
CREATE INDEX IF NOT EXISTS idx_submissions_user_id ON public.submissions(user_id);
CREATE INDEX IF NOT EXISTS idx_submissions_store_id ON public.submissions(store_id);
CREATE INDEX IF NOT EXISTS idx_submissions_status ON public.submissions(status);
CREATE INDEX IF NOT EXISTS idx_submissions_submitted_at ON public.submissions(submitted_at DESC);
CREATE INDEX IF NOT EXISTS idx_submission_items_submission_id ON public.submission_items(submission_id);
CREATE INDEX IF NOT EXISTS idx_submission_items_offer_id ON public.submission_items(offer_id);

-- 5. Enable RLS
ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.submission_items ENABLE ROW LEVEL SECURITY;

-- 6. Drop existing policies if any
DROP POLICY IF EXISTS "Users can insert their own submissions" ON public.submissions;
DROP POLICY IF EXISTS "Users can view their own submissions" ON public.submissions;
DROP POLICY IF EXISTS "Users can update their own pending submissions" ON public.submissions;
DROP POLICY IF EXISTS "Users can delete their own pending submissions" ON public.submissions;
DROP POLICY IF EXISTS "Users can insert items for their own submissions" ON public.submission_items;
DROP POLICY IF EXISTS "Users can view items for their own submissions" ON public.submission_items;
DROP POLICY IF EXISTS "Users can update items for their own pending submissions" ON public.submission_items;
DROP POLICY IF EXISTS "Users can delete items from their own pending submissions" ON public.submission_items;

-- 7. Create RLS policies for submissions
CREATE POLICY "Users can insert their own submissions"
ON public.submissions FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own submissions"
ON public.submissions FOR SELECT TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own pending submissions"
ON public.submissions FOR UPDATE TO authenticated
USING (auth.uid() = user_id AND status = 'pending')
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own pending submissions"
ON public.submissions FOR DELETE TO authenticated
USING (auth.uid() = user_id AND status = 'pending');

-- 8. Create RLS policies for submission_items
CREATE POLICY "Users can insert items for their own submissions"
ON public.submission_items FOR INSERT TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.submissions
        WHERE id = submission_id AND user_id = auth.uid()
    )
);

CREATE POLICY "Users can view items for their own submissions"
ON public.submission_items FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.submissions
        WHERE id = submission_id AND user_id = auth.uid()
    )
);

CREATE POLICY "Users can update items for their own pending submissions"
ON public.submission_items FOR UPDATE TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.submissions
        WHERE id = submission_id AND user_id = auth.uid() AND status = 'pending'
    )
);

CREATE POLICY "Users can delete items from their own pending submissions"
ON public.submission_items FOR DELETE TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.submissions
        WHERE id = submission_id AND user_id = auth.uid() AND status = 'pending'
    )
);

-- 9. Drop existing storage policies if any
DROP POLICY IF EXISTS "Users can upload their own receipts" ON storage.objects;
DROP POLICY IF EXISTS "Users can read their own receipts" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own receipts" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own receipts" ON storage.objects;

-- 10. Create storage policies
CREATE POLICY "Users can upload their own receipts"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
    bucket_id = 'receipts' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can read their own receipts"
ON storage.objects FOR SELECT TO authenticated
USING (
    bucket_id = 'receipts' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can update their own receipts"
ON storage.objects FOR UPDATE TO authenticated
USING (
    bucket_id = 'receipts' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete their own receipts"
ON storage.objects FOR DELETE TO authenticated
USING (
    bucket_id = 'receipts' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 11. Create updated_at trigger function
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_updated_at ON public.submissions;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.submissions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 12. Grant permissions
GRANT ALL ON public.submissions TO authenticated;
GRANT ALL ON public.submission_items TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

COMMIT;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'SUCCESS: All tables, policies, and storage bucket created successfully!';
END $$;
```

---

## How to Run

### Option 1: Step by Step (Recommended for first-time setup)
1. Open Supabase Dashboard
2. Go to **SQL Editor**
3. Create a **New Query**
4. Copy and paste each section (1-10) one at a time
5. Click **Run** after each section
6. Verify no errors appear

### Option 2: All at Once (Quick setup)
1. Open Supabase Dashboard
2. Go to **SQL Editor**
3. Create a **New Query**
4. Copy the entire "Quick Setup Script" section
5. Click **Run**
6. Should see: "SUCCESS: All tables, policies, and storage bucket created successfully!"

---

## Verification Commands

After running the setup, verify everything is working:

```sql
-- 1. Check tables
SELECT table_name, table_type 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('submissions', 'submission_items')
ORDER BY table_name;

-- 2. Check storage bucket
SELECT id, name, public, created_at 
FROM storage.buckets 
WHERE id = 'receipts';

-- 3. Count policies
SELECT 
    'submissions' as table_name,
    COUNT(*) as policy_count
FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'submissions'
UNION ALL
SELECT 
    'submission_items',
    COUNT(*)
FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'submission_items'
UNION ALL
SELECT 
    'storage.objects (receipts)',
    COUNT(*)
FROM pg_policies 
WHERE schemaname = 'storage' 
AND tablename = 'objects' 
AND policyname LIKE '%receipt%';

-- 4. View all policies
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd as operation,
    roles
FROM pg_policies 
WHERE (
    (schemaname = 'public' AND tablename IN ('submissions', 'submission_items'))
    OR (schemaname = 'storage' AND policyname LIKE '%receipt%')
)
ORDER BY schemaname, tablename, policyname;
```

Expected results:
- ✅ 2 tables: `submissions`, `submission_items`
- ✅ 1 storage bucket: `receipts`
- ✅ 4 policies on `submissions`
- ✅ 4 policies on `submission_items`
- ✅ 4 policies on storage for receipts

---

## Troubleshooting

### Error: "relation already exists"
This is fine! It means the table was already created. You can continue.

### Error: "policy already exists"
Run the DROP POLICY commands first, then recreate them.

### Error: "foreign key constraint"
Make sure your `stores` and `offers` tables exist first. If not, create them before running this script.

### Error: "bucket already exists"
The bucket was already created. You can skip bucket creation or use `ON CONFLICT DO NOTHING`.

---

**Created:** March 22, 2026
**Last Updated:** March 22, 2026
