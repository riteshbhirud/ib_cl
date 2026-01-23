# 🚀 SUPABASE INTEGRATION GUIDE

## ⚠️ IMPORTANT: Manual Steps Required

### Step 1: Add Supabase Swift Package to Xcode

**You MUST do this manually in Xcode:**

1. Open your project in Xcode
2. Go to **File** → **Add Package Dependencies**
3. Paste this URL: `i `
4. Choose "Up to Next Major Version" starting from **2.0.0**
5. Click **Add Package**
6. Select **Supabase** library
7. Click **Add Package** again

**Without this step, the app will NOT compile!**

---

## ✅ Files Already Created

I've created these files for you:

### Config
- ✅ `Config/SupabaseConfig.swift` - Your Supabase credentials
- ✅ `Services/SupabaseManager.swift` - Singleton manager

### Models
- ✅ `Models/UserProfile.swift` - User profile with proper CodingKeys

---

## 📋 What I'll Create Next

I'm creating all the service files that will handle:

1. **AuthService** - Login, signup, session management
2. **StoreService** - Fetch stores from Supabase
3. **OfferService** - Fetch offers per store
4. **UserListService** - Manage user's saved offers
5. **SubmissionService** - Receipt uploads & submissions
6. **AccountService** - Balance, transactions, withdrawals

---

## 🎯 Integration Strategy

Instead of replacing everything at once, I'll create a **hybrid approach**:

### Option A: Keep Mock Data (Recommended for Testing)
- Use existing MockData for development
- Add Supabase services alongside
- Toggle between mock and real data with a flag

### Option B: Full Supabase Migration
- Replace all mock data immediately
- Requires Supabase tables to be populated
- App won't work without internet

---

## 🔧 Recommended Approach: Feature Flags

I'll add a simple flag system:

```swift
enum DataSource {
    case mock      // Use existing mock data
    case supabase  // Use real Supabase
}

struct AppConfig {
    static var dataSource: DataSource = .mock // Switch this when ready!
}
```

This way you can:
- ✅ Test with mock data while building
- ✅ Switch to Supabase when ready
- ✅ No errors during development

---

## 📝 Your Supabase Tables Must Match

Make sure your Supabase has these tables:

### Required Tables:
- `user_profiles` - User accounts
- `stores` - Store list
- `offers` - Cashback offers
- `user_offer_lists` - User's saved offers
- `submissions` - Receipt submissions
- `submission_items` - Items in each submission
- `transactions` - Balance transactions
- `withdrawal_requests` - Withdrawal history

### Column Names Must Use snake_case:
- `full_name` (not `fullName`)
- `created_at` (not `createdAt`)
- `store_id` (not `storeId`)
- etc.

---

## 🎬 Next Steps

### After I Create All Files:

1. **Add Supabase Package** (manual step above)
2. **Build project** - should compile without errors
3. **Start with Mock Data** - App works as before
4. **Test One Feature** - Try login with Supabase
5. **Gradually migrate** - Switch features one by one

---

## 🐛 Troubleshooting

### "Cannot find 'Supabase' in scope"
- ❌ Package not added to Xcode
- ✅ Follow Step 1 above

### "No such table: stores"
- ❌ Supabase tables not created yet
- ✅ Create tables in Supabase dashboard

### "Column not found"
- ❌ Column names don't match (camelCase vs snake_case)
- ✅ Update Supabase columns to use snake_case

---

## 📱 Testing Plan

1. **Phase 1: Mock Data (Current)**
   - Everything works offline
   - No Supabase needed
   - Perfect for development

2. **Phase 2: Auth Only**
   - Enable Supabase for login/signup
   - Keep mock data for offers/stores
   - Test authentication flow

3. **Phase 3: Read Data**
   - Fetch stores from Supabase
   - Fetch offers from Supabase
   - Still use mock for submissions

4. **Phase 4: Full Integration**
   - All features use Supabase
   - Receipt uploads work
   - Submissions save to database

---

**Ready to proceed? I'll create all the service files now!**
