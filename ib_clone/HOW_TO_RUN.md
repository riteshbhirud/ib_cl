# 🚀 How to Run the App in Xcode Simulator

## Quick Start (3 Steps)

### Step 1: Open the Project
1. In Xcode, make sure your project is open
2. You should see all the files in the Project Navigator (left sidebar)

### Step 2: Select a Simulator
1. At the top of Xcode, near the center, you'll see a device selector (looks like "iPhone 15 Pro" or similar)
2. Click on it to see available simulators
3. Choose any iPhone simulator (recommended: **iPhone 15 Pro** or **iPhone 14 Pro**)
   - If you don't see any simulators, go to: **Xcode** menu → **Settings** → **Platforms** → Download iOS Simulator

### Step 3: Build and Run
1. Press **⌘ + R** (Command + R) OR
2. Click the **Play ▶️** button in the top-left corner of Xcode

### What Happens Next
- Xcode will compile the app (may take 30-60 seconds first time)
- The iOS Simulator will launch automatically
- The app will open showing the **Home screen** with stores

---

## 🎯 What You'll See

### Home Tab (Opens First)
- Greeting with your balance at the top
- Search bar
- "Featured Stores" horizontal scroll (Walmart, Target, CVS)
- "All Stores" grid below with 6 stores
- Tap any store to see offers!

### My List Tab
- Initially empty with a friendly message
- Add offers from stores to see items here
- Organized by store with quantity controls

### Activity Tab
- Shows sample submissions (Pending, Approved, Rejected)
- Filter by status
- Tap any submission to see details

### Account Tab
- Profile with avatar
- Balance card showing $24.50 (mock data)
- Can withdraw since balance > $15
- Transaction history
- Settings menu

---

## 🎮 Try These Interactions

1. **Browse Offers**
   - Tap "Walmart" on Home screen
   - See offers grid with filters at top
   - Scroll through offers
   - Tap any offer for details

2. **Add to List**
   - Tap the "+" button on any offer card
   - Watch it animate to checkmark ✓
   - See "My List (1)" button appear at bottom
   - Feel the haptic feedback!

3. **View Offer Details**
   - Tap an offer card (not the + button)
   - See large image, cashback, details
   - Adjust quantity with +/- buttons
   - Tap "Add to List"

4. **Manage Your List**
   - Go to "My List" tab (bottom bar)
   - See your added offers by store
   - Swipe left to delete
   - Adjust quantities with +/- buttons

5. **Redeem Flow**
   - In My List, tap "Redeem at [Store]"
   - Tap "Take Photo" or "Choose from Library"
   - Select items and quantities
   - Submit for review
   - See success animation!

6. **Check Balance**
   - Go to Account tab
   - See balance card (gradient with $24.50)
   - Tap "Withdraw Funds"
   - Enter amount (min $15)
   - Try quick amount buttons

---

## 🐛 Troubleshooting

### If build fails:
1. **Clean Build Folder**: **Product** menu → **Clean Build Folder** (⌘ + Shift + K)
2. **Restart Xcode**: Quit and reopen
3. **Update Simulator**: Make sure you're using iOS 17.0+ simulator

### If simulator is slow:
1. Choose a simpler device (iPhone SE)
2. Close other apps
3. **Hardware** menu in Simulator → **Erase All Content and Settings**

### Can't find the Play button?
- It's in the top-left corner of Xcode window
- Looks like ▶️ (play triangle)
- Next to the device selector

---

## 📱 Simulator Tips

### Useful Simulator Shortcuts:
- **⌘ + Left/Right Arrow**: Rotate device
- **⌘ + Shift + H**: Home button (go to home screen)
- **⌘ + K**: Toggle keyboard
- **⌘ + 1**: 100% size
- **⌘ + 2**: 75% size (if simulator is too big)
- **⌘ + 3**: 50% size

### Test Dark Mode:
1. In Simulator, go to **Settings** app
2. Tap **Developer** (might need to enable in Features menu)
3. Toggle **Dark Appearance**
4. Or use Simulator menu: **Features** → **Toggle Appearance**

---

## ✨ What to Look For

### Design Elements:
- **Smooth animations** when tapping cards
- **Haptic feedback** when adding offers (if on real device)
- **Skeleton loading** when pulling to refresh
- **Beautiful gradients** on balance card
- **Badges** on offers (Expiring Soon, Free After Offer, Bonus)
- **Dark mode** support throughout

### Navigation:
- **Tab bar** at bottom (4 tabs)
- **Smooth transitions** between screens
- **Back buttons** work correctly
- **Badge count** on My List tab shows item count

### Interactions:
- **Pull to refresh** on Home screen
- **Search** stores by name
- **Filters** on store detail (All, Expiring Soon, etc.)
- **Quantity selectors** with +/- buttons
- **Swipe to delete** in My List

---

## 🎉 Enjoy!

The app is fully functional with mock data. Everything works end-to-end:
- ✅ Browse stores and offers
- ✅ Add items to your list
- ✅ Adjust quantities
- ✅ Submit receipts (mock)
- ✅ Track submissions
- ✅ View balance and withdraw

Have fun exploring! The UI is polished and smooth - it should feel like a real production app! 🚀
