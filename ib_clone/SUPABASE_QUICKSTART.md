# 🚀 SUPABASE QUICK START GUIDE

## ✅ What's Been Created

All Supabase integration files are now in your project!

### Services Created:
- ✅ `Config/SupabaseConfig.swift` - Your credentials
- ✅ `Services/SupabaseManager.swift` - Singleton client
- ✅ `Services/AuthService.swift` - Authentication
- ✅ `Services/StoreService.swift` - Store data
- ✅ `Services/OfferService.swift` - Offer data
- ✅ `Services/UserListService.swift` - User's saved offers
- ✅ `Services/SubmissionService.swift` - Receipt submissions
- ✅ `Services/AccountService.swift` - Balance & withdrawals

### Models Created:
- ✅ `Models/UserProfile.swift` - User profile with snake_case keys
- ✅ `Models/WithdrawalRequest.swift` - Withdrawal tracking

---

## 🔧 STEP 1: Add Supabase Package (REQUIRED!)

**You MUST do this in Xcode:**

1. Open Xcode
2. Click **File** → **Add Package Dependencies...**
3. Paste URL: `https://github.com/supabase/supabase-swift`
4. Choose **"Up to Next Major Version"** from **2.0.0**
5. Click **Add Package**
6. Select **"Supabase"** library
7. Click **Add Package** again

**The project will NOT compile without this step!**

---

## 📋 STEP 2: Update Your Supabase Credentials

Open `Config/SupabaseConfig.swift` and update if needed:

```swift
static let url = URL(string: "https://unkeswdiectufubntibs.supabase.co")!
static let anonKey = "YOUR_ANON_KEY_HERE" // Update this!
```

---

## 🎯 STEP 3: Choose Your Integration Path

### Option A: Keep Mock Data (Recommended First)

Your app currently works with mock data. **Keep it that way!**

Benefits:
- ✅ App works immediately
- ✅ No internet required
- ✅ Perfect for development
- ✅ Test UI without backend

You can add Supabase features gradually:
1. Start with just Auth (login/signup)
2. Add real stores/offers later
3. Finally add submissions

### Option B: Full Supabase Now

Switch everything to Supabase immediately.

Requirements:
- ❌ Requires Supabase tables to be populated
- ❌ Requires internet connection
- ❌ More setup needed first

---

## 🏗️ STEP 4: Prepare Your Supabase Tables

Your Supabase database needs these tables with snake_case columns:

### Required Tables:

**user_profiles**
```sql
- id: uuid (primary key, references auth.users)
- email: text
- full_name: text
- avatar_url: text
- balance: numeric default 0
- total_earned: numeric default 0
- total_withdrawn: numeric default 0
- created_at: timestamp
- updated_at: timestamp
```

**stores**
```sql
- id: uuid (primary key, default gen_random_uuid())
- name: text
- logo_url: text
- description: text
- is_active: boolean default true
- sort_order: integer
- created_at: timestamp
```

**offers**
```sql
- id: uuid (primary key, default gen_random_uuid())
- store_id: uuid (foreign key → stores.id)
- offer_id: text
- slug: text
- name: text
- image_url: text
- cashback: numeric
- cashback_text: text
- details: text
- offer_detail: text
- special_tag: text
- purchase_requirement: text
- redemption_limit: integer default 5
- expiring_soon: boolean default false
- has_bonus: boolean default false
- is_active: boolean default true
- expires_at: timestamp
- created_at: timestamp
```

**user_offer_lists**
```sql
- id: uuid (primary key, default gen_random_uuid())
- user_id: uuid (foreign key → auth.users.id)
- offer_id: uuid (foreign key → offers.id)
- store_id: uuid (foreign key → stores.id)
- quantity: integer default 1
- added_at: timestamp default now()
UNIQUE constraint on (user_id, offer_id)
```

**submissions**
```sql
- id: uuid (primary key, default gen_random_uuid())
- user_id: uuid (foreign key → auth.users.id)
- store_id: uuid (foreign key → stores.id)
- receipt_image_url: text
- total_cashback: numeric
- status: text default 'pending' (pending/approved/rejected)
- rejection_reason: text
- submitted_at: timestamp default now()
- reviewed_at: timestamp
```

**submission_items**
```sql
- id: uuid (primary key, default gen_random_uuid())
- submission_id: uuid (foreign key → submissions.id)
- offer_id: uuid (foreign key → offers.id)
- offer_name: text
- quantity: integer
- cashback_per_item: numeric
- total_cashback: numeric
```

**transactions**
```sql
- id: uuid (primary key, default gen_random_uuid())
- user_id: uuid (foreign key → auth.users.id)
- type: text (credit/withdrawal/bonus/adjustment)
- amount: numeric
- description: text
- submission_id: uuid (nullable, foreign key → submissions.id)
- created_at: timestamp default now()
```

**withdrawal_requests**
```sql
- id: uuid (primary key, default gen_random_uuid())
- user_id: uuid (foreign key → auth.users.id)
- amount: numeric
- status: text default 'pending'
- payment_method: text
- payment_reference: text
- requested_at: timestamp default now()
- processed_at: timestamp
```

### Storage Buckets:

Create a bucket named **"receipts"** for receipt images:
- Enable public access or use signed URLs
- Set max file size to 10MB
- Allow image uploads (jpg, png)

---

## 💡 STEP 5: Test with Mock Data First

Your existing app already works! Before switching to Supabase:

1. ✅ **Build & Run** - Make sure everything still works
2. ✅ **Test Features** - Browse stores, add to list, etc.
3. ✅ **UI is Perfect** - All screens look good

---

## 🔄 STEP 6: Gradual Migration Plan

### Phase 1: Add Authentication Only

Keep your existing `AppState` but add auth:

1. Create login/signup views
2. Use `AuthService` for authentication
3. Keep all other data as mock
4. Users can sign in but see mock data

### Phase 2: Fetch Stores & Offers

Update `HomeViewModel` to use `StoreService`:

```swift
// In HomeViewModel
private let storeService = StoreService()

func fetchStores() async {
    do {
        stores = try await storeService.fetchStoresWithOfferCounts()
    } catch {
        // Handle error
    }
}
```

### Phase 3: User Lists

Update `MyListViewModel` to use `UserListService`:

```swift
// In MyListViewModel
private let userListService = UserListService()

func fetchList(userId: UUID) async {
    do {
        listItems = try await userListService.fetchUserLists(userId: userId)
    } catch {
        // Handle error
    }
}
```

### Phase 4: Submissions

Update `RedeemViewModel` to use `SubmissionService`:

```swift
// In RedeemViewModel
private let submissionService = SubmissionService()

func submitReceipt(userId: UUID, storeId: UUID) async {
    // Upload image and create submission
}
```

---

## 🎮 STEP 7: Example Usage

### How to Use AuthService:

```swift
import SwiftUI

struct LoginView: View {
    @State private var authService = AuthService()
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            
            Button("Sign In") {
                Task {
                    try await authService.signIn(email: email, password: password)
                }
            }
        }
    }
}
```

### How to Fetch Stores:

```swift
@MainActor
class HomeViewModel: ObservableObject {
    @Published var stores: [Store] = []
    private let storeService = StoreService()
    
    func loadStores() async {
        do {
            stores = try await storeService.fetchStoresWithOfferCounts()
        } catch {
            print("Error loading stores: \(error)")
        }
    }
}
```

### How to Add to List:

```swift
let userListService = UserListService()

// Add offer to list
try await userListService.addToList(
    userId: userId,
    offerId: offer.id,
    storeId: store.id,
    quantity: 2
)
```

---

## ⚠️ Common Issues & Solutions

### Error: "Cannot find 'Supabase' in scope"
**Fix:** Add Supabase package in Xcode (Step 1)

### Error: "No such table: stores"
**Fix:** Create tables in Supabase dashboard (Step 4)

### Error: "Column 'full_name' not found"
**Fix:** Use snake_case in Supabase, not camelCase

### Error: "Authentication required"
**Fix:** User must be logged in to access protected tables

---

## 🎉 Success Checklist

- [ ] Supabase package added to Xcode
- [ ] Config file has correct credentials
- [ ] Project builds without errors
- [ ] Can run app with mock data
- [ ] Supabase tables created (when ready)
- [ ] Auth works (when ready)
- [ ] Can fetch real data (when ready)

---

## 🚀 Next Steps

1. **Add Supabase Package** (required to build)
2. **Build & Run** - Should work with mock data
3. **Create Supabase Tables** - When you're ready
4. **Test Authentication** - Sign up/login
5. **Migrate Features** - One at a time

**Start with Step 1 now - add the Supabase package!**

---

## 📞 Need Help?

- Supabase docs: https://supabase.com/docs
- Swift client: https://github.com/supabase/supabase-swift
- Check table names match (snake_case!)
- Verify columns exist in Supabase

**Your app is ready for Supabase integration! 🎊**
