# Camera Scanner Fixes - Quick Guide

## Issues Fixed ✅

### 1. App Crashes on Real Device
**Problem:** App freezes/crashes when trying to open camera
**Cause:** Missing camera permission in Info.plist
**Status:** ✅ Code updated, requires Info.plist configuration

### 2. Blank Screen in Simulator  
**Problem:** Just see scanner rectangle but no camera view
**Cause:** Simulator doesn't have a camera
**Status:** ✅ Fixed with simulator fallback UI

---

## 🔧 Required Setup Steps

### Step 1: Add Camera Permission to Info.plist

**You MUST do this for the app to work on a real device!**

#### Method A: Using Property List Editor (Easy)
1. In Xcode, navigate to your project
2. Select the `ib_clone` target
3. Go to the **Info** tab
4. Find "Custom iOS Target Properties" section
5. Click the **`+`** button
6. Select **"Privacy - Camera Usage Description"** from the dropdown
7. Set the value to: **"We need camera access to scan receipt barcodes for cashback redemption"**

#### Method B: Edit Info.plist as Source Code
1. In Project Navigator, find `Info.plist`
2. Right-click → **Open As** → **Source Code**
3. Add this inside the main `<dict>` tags:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan receipt barcodes for cashback redemption</string>
```

4. Save the file

---

## 🎯 What's Changed in Code

### BarcodeScannerView.swift - New Features:

1. **✅ Simulator Detection**
   - Automatically detects if running on simulator
   - Shows a clean fallback UI with "Use Test Barcode" button
   - Generates mock receipt image for testing

2. **✅ Permission Handling**
   - Checks camera permission status before accessing camera
   - Requests permission if not determined
   - Shows helpful "Open Settings" screen if denied

3. **✅ Better Error Messages**
   - Clear feedback when camera can't be accessed
   - Console logging for debugging
   - User-friendly error screens

---

## 📱 Testing Guide

### On Simulator:
1. Run the app in simulator
2. Go through redeem flow
3. When scanner opens, you'll see:
   - "Simulator Mode" message
   - "Use Test Barcode" button
4. Click the button to simulate a scan
5. You'll proceed to item selection with mock data

### On Real Device (First Time):
1. **Make sure Info.plist is configured!**
2. Run app on device
3. Go through redeem flow
4. When scanner opens:
   - You'll see a system permission alert
   - Tap "Allow" to grant camera access
   - Camera preview will appear
   - Point at any barcode to scan

### On Real Device (Permission Denied):
1. If you previously denied permission
2. App will show "Camera Access Denied" screen
3. Tap "Open Settings" button
4. Enable camera access for ib_clone
5. Return to app and try again

---

## 🧪 Test Barcode Generation

The simulator mode generates realistic test data:
- Random test barcode: `TEST-RECEIPT-XXXXXXXX`
- Mock receipt image with:
  - Store name
  - Current date/time
  - Barcode visualization
- Proceeds normally through the flow

---

## 🐛 Troubleshooting

### App still crashes on device:
- ✅ Double-check Info.plist has camera permission
- ✅ Clean build folder: Cmd + Shift + K
- ✅ Delete app from device and reinstall

### Camera is black/frozen:
- ✅ Check device Settings → Privacy → Camera → ib_clone is ON
- ✅ Restart the app
- ✅ Check console for error messages

### Simulator button doesn't work:
- ✅ Make sure you're on the simulator (should see the fallback UI)
- ✅ Check console for any errors
- ✅ Try restarting simulator

---

## 📋 Quick Checklist

Before testing:
- [ ] Added camera permission to Info.plist
- [ ] Cleaned and rebuilt the project
- [ ] Deleted old app version from test device
- [ ] Installed fresh build

---

## 💡 Additional Notes

### Camera Permission String
The usage description tells users why you need camera access. It appears in:
- System permission dialog
- Settings app under your app's permissions

### Simulator Limitations
Simulators can't access:
- Real camera hardware
- AVFoundation video capture
- Barcode scanning (Vision framework works but needs video feed)

That's why we provide a test mode!

### Production Considerations
For production release, you may want to:
- Add more descriptive permission message
- Implement manual barcode entry as backup
- Add photo library option for scanning saved receipt photos
- Improve test data generation for QA testing

---

## ✨ What Users Will Experience

### Real Device Flow:
1. Tap "Redeem at [Store]"
2. See requirements popup
3. Tap "I Understand, Continue"  
4. **[First time]** See permission dialog → Tap "Allow"
5. Camera opens with scanning frame
6. Point at receipt barcode
7. Automatic detection with success animation
8. Proceed to item selection

### Simulator Flow:
1. Tap "Redeem at [Store]"
2. See requirements popup
3. Tap "I Understand, Continue"
4. See "Simulator Mode" screen
5. Tap "Use Test Barcode"
6. Automatic success animation
7. Proceed to item selection with test data

---

**Created:** March 22, 2026
**Last Updated:** March 22, 2026
