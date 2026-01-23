-- Supabase Database Schema for Cashback App
-- Run this in your Supabase SQL Editor

-- ============================================
-- ENABLE UUID EXTENSION
-- ============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- USER PROFILES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    full_name TEXT,
    avatar_url TEXT,
    balance NUMERIC DEFAULT 0,
    total_earned NUMERIC DEFAULT 0,
    total_withdrawn NUMERIC DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS Policies for user_profiles
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON public.user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.user_profiles
    FOR UPDATE USING (auth.uid() = id);

-- Trigger to create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', '')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- STORES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.stores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    logo_url TEXT,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS Policies for stores
ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Stores are viewable by everyone" ON public.stores
    FOR SELECT USING (is_active = TRUE);

-- Insert sample stores
INSERT INTO public.stores (name, description, sort_order) VALUES
    ('Walmart', 'Save money. Live better.', 1),
    ('Target', 'Expect More. Pay Less.', 2),
    ('CVS Pharmacy', 'Health is everything', 3),
    ('Walgreens', 'Trusted since 1901', 4),
    ('Kroger', 'Fresh for Everyone', 5),
    ('Costco', 'The Warehouse Wholesaler', 6)
ON CONFLICT DO NOTHING;

-- ============================================
-- OFFERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.offers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
    offer_id TEXT,
    slug TEXT,
    name TEXT NOT NULL,
    image_url TEXT,
    cashback NUMERIC NOT NULL,
    cashback_text TEXT,
    details TEXT,
    offer_detail TEXT,
    special_tag TEXT,
    purchase_requirement TEXT,
    redemption_limit INTEGER DEFAULT 5,
    expiring_soon BOOLEAN DEFAULT FALSE,
    has_bonus BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_offers_store_id ON public.offers(store_id);
CREATE INDEX IF NOT EXISTS idx_offers_is_active ON public.offers(is_active);

-- RLS Policies for offers
ALTER TABLE public.offers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Offers are viewable by everyone" ON public.offers
    FOR SELECT USING (is_active = TRUE);

-- ============================================
-- USER OFFER LISTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_offer_lists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    offer_id UUID NOT NULL REFERENCES public.offers(id) ON DELETE CASCADE,
    store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
    quantity INTEGER DEFAULT 1 CHECK (quantity > 0),
    added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, offer_id)
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_user_offer_lists_user_id ON public.user_offer_lists(user_id);
CREATE INDEX IF NOT EXISTS idx_user_offer_lists_store_id ON public.user_offer_lists(store_id);

-- RLS Policies for user_offer_lists
ALTER TABLE public.user_offer_lists ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own lists" ON public.user_offer_lists
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own lists" ON public.user_offer_lists
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own lists" ON public.user_offer_lists
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own lists" ON public.user_offer_lists
    FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- SUBMISSIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
    receipt_image_url TEXT NOT NULL,
    total_cashback NUMERIC NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    rejection_reason TEXT,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_at TIMESTAMP WITH TIME ZONE
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_submissions_user_id ON public.submissions(user_id);
CREATE INDEX IF NOT EXISTS idx_submissions_status ON public.submissions(status);

-- RLS Policies for submissions
ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own submissions" ON public.submissions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own submissions" ON public.submissions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- SUBMISSION ITEMS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.submission_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    submission_id UUID NOT NULL REFERENCES public.submissions(id) ON DELETE CASCADE,
    offer_id UUID NOT NULL REFERENCES public.offers(id) ON DELETE CASCADE,
    offer_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    cashback_per_item NUMERIC NOT NULL,
    total_cashback NUMERIC NOT NULL
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_submission_items_submission_id ON public.submission_items(submission_id);

-- RLS Policies for submission_items
ALTER TABLE public.submission_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own submission items" ON public.submission_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.submissions
            WHERE submissions.id = submission_items.submission_id
            AND submissions.user_id = auth.uid()
        )
    );

-- ============================================
-- TRANSACTIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('credit', 'withdrawal', 'bonus', 'adjustment')),
    amount NUMERIC NOT NULL,
    description TEXT,
    submission_id UUID REFERENCES public.submissions(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON public.transactions(user_id);

-- RLS Policies for transactions
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own transactions" ON public.transactions
    FOR SELECT USING (auth.uid() = user_id);

-- ============================================
-- WITHDRAWAL REQUESTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.withdrawal_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    amount NUMERIC NOT NULL CHECK (amount >= 15),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    payment_method TEXT DEFAULT 'paypal',
    payment_reference TEXT,
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_withdrawal_requests_user_id ON public.withdrawal_requests(user_id);

-- RLS Policies for withdrawal_requests
ALTER TABLE public.withdrawal_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own withdrawal requests" ON public.withdrawal_requests
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own withdrawal requests" ON public.withdrawal_requests
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Function to update user balance when submission is approved
CREATE OR REPLACE FUNCTION public.handle_submission_approval()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
        -- Update user balance
        UPDATE public.user_profiles
        SET 
            balance = balance + NEW.total_cashback,
            total_earned = total_earned + NEW.total_cashback
        WHERE id = NEW.user_id;
        
        -- Create transaction record
        INSERT INTO public.transactions (user_id, type, amount, description, submission_id)
        VALUES (NEW.user_id, 'credit', NEW.total_cashback, 'Cashback from receipt approval', NEW.id);
        
        -- Set reviewed_at timestamp
        NEW.reviewed_at = NOW();
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_submission_status_change
    BEFORE UPDATE ON public.submissions
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM NEW.status)
    EXECUTE FUNCTION public.handle_submission_approval();

-- Function to handle withdrawal processing
CREATE OR REPLACE FUNCTION public.handle_withdrawal_completion()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        -- Deduct from user balance
        UPDATE public.user_profiles
        SET 
            balance = balance - NEW.amount,
            total_withdrawn = total_withdrawn + NEW.amount
        WHERE id = NEW.user_id;
        
        -- Create transaction record
        INSERT INTO public.transactions (user_id, type, amount, description)
        VALUES (NEW.user_id, 'withdrawal', NEW.amount, 'Withdrawal to ' || COALESCE(NEW.payment_method, 'PayPal'));
        
        -- Set processed_at timestamp
        NEW.processed_at = NOW();
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_withdrawal_status_change
    BEFORE UPDATE ON public.withdrawal_requests
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM NEW.status)
    EXECUTE FUNCTION public.handle_withdrawal_completion();

-- ============================================
-- STORAGE BUCKET FOR RECEIPTS
-- ============================================

-- Create storage bucket (run in SQL editor or Storage UI)
INSERT INTO storage.buckets (id, name, public)
VALUES ('receipts', 'receipts', false)
ON CONFLICT DO NOTHING;

-- Storage policies for receipts bucket
CREATE POLICY "Users can upload own receipts"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'receipts'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can view own receipts"
ON storage.objects FOR SELECT
USING (
    bucket_id = 'receipts'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- ============================================
-- SAMPLE DATA (OPTIONAL)
-- ============================================

-- You can add sample offers here for testing
-- Example:
/*
INSERT INTO public.offers (store_id, name, cashback, cashback_text, redemption_limit)
SELECT 
    id,
    'Sample Offer - ' || name,
    2.50,
    '$2.50 back',
    5
FROM public.stores
LIMIT 1;
*/

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Run these to verify everything is set up correctly:
-- SELECT * FROM public.stores;
-- SELECT * FROM public.user_profiles;
-- SELECT tablename FROM pg_tables WHERE schemaname = 'public';
