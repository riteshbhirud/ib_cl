# iOS Cashback App (Ibotta Clone)

A modern, fully-featured iOS cashback/rebate app built with SwiftUI following MVVM architecture.

## 🎨 Features

### Core Functionality
- **Home Screen**: Browse featured and all available stores with search functionality
- **Store Details**: View all offers available at each store with filters (All, Expiring Soon, Free After Offer, Bonus)
- **Offer Details**: Detailed view of each offer with quantity selector and add-to-list functionality
- **My List**: Manage saved offers organized by store with quantity controls
- **Redeem Flow**: Capture receipt photos and submit for cashback approval
- **Activity**: Track submission status (Pending, Approved, Rejected) with detailed views
- **Account**: View balance, request withdrawals, transaction history, and account settings

### Design System
- **Colors**: Modern coral red (#FF6B6B) and teal (#4ECDC4) color scheme
- **Typography**: Clean SF font hierarchy with clear visual hierarchy
- **Components**: Reusable, polished UI components
- **Dark Mode**: Full support for light and dark mode
- **Animations**: Smooth transitions, haptic feedback, and micro-interactions

## 📁 Project Structure

```
ib_clone/
├── Theme/               # Design system (Colors, Typography, Spacing)
├── Models/              # Data models (Store, Offer, User, etc.)
├── Mock/                # Mock data for development
├── Components/          # Reusable UI components
├── Extensions/          # View and utility extensions
├── App/                 # App state management
├── Features/
│   ├── Home/           # Store browsing
│   ├── Store/          # Store details and offers
│   ├── MyList/         # Saved offers management
│   ├── Redeem/         # Receipt capture and submission
│   ├── Activity/       # Submission history
│   └── Account/        # User account and balance
└── Views/              # Main tab view
```

## 🛠 Tech Stack

- **SwiftUI**: Declarative UI framework
- **MVVM Architecture**: Clear separation of concerns
- **Swift Concurrency**: async/await for all async operations
- **@Observable**: iOS 17+ state management
- **NavigationStack**: Modern navigation system
- **PhotosUI**: Camera and photo library integration

## 🎯 Key Components

### Reusable Components
- `PrimaryButton`: Customizable button with loading states
- `CashbackBadge`: Green cashback amount display
- `OfferCard`: Grid card for offers with badges
- `StoreCard`: Store display card
- `QuantitySelector`: Increment/decrement quantity control
- `LoadingView`: Skeleton loading states
- `EmptyStateView`: Empty state with optional actions

### View Models
- `HomeViewModel`: Manages store list and search
- `StoreViewModel`: Handles offers and filters
- `MyListViewModel`: Manages user's saved offers
- `RedeemViewModel`: Handles receipt submission flow
- `ActivityViewModel`: Manages submission history
- `AccountViewModel`: Handles balance and withdrawals

### Models
- `Store`: Store information
- `Offer`: Cashback offer details
- `User`: User account and balance
- `UserOfferListItem`: Saved offers in user's list
- `Submission`: Receipt submission with status
- `Transaction`: Balance transactions

## 🚀 Getting Started

1. Open `ib_clone.xcodeproj` in Xcode 15+
2. Build and run on iOS 17+ simulator or device
3. The app starts with mock data pre-loaded

## 📱 Main User Flows

### 1. Browse & Add Offers
1. Browse stores on Home screen
2. Tap a store to view offers
3. Tap an offer to see details
4. Select quantity and add to list

### 2. Redeem Offers
1. Go to My List tab
2. Select a store with items
3. Tap "Redeem at [Store]"
4. Capture receipt photo
5. Select purchased items
6. Submit for review

### 3. Track & Withdraw
1. View submissions in Activity tab
2. Check balance in Account tab
3. Request withdrawal when balance ≥ $15

## 🎨 Design Highlights

- **Smooth Animations**: Press animations, transitions, matched geometry
- **Haptic Feedback**: Tactile responses for key interactions
- **Loading States**: Skeleton screens and shimmer effects
- **Empty States**: Helpful guidance when content is empty
- **Error Handling**: User-friendly error messages
- **Accessibility**: Proper labels and semantic structures

## 📝 Mock Data

The app includes comprehensive mock data:
- 6 sample stores (Walmart, Target, CVS, Walgreens, Kroger, Costco)
- 20+ sample offers across stores
- Sample user with balance and transaction history
- Sample submissions in various states

## 🔧 Customization

### Colors
Edit `Theme/Colors.swift` to customize the color scheme:
```swift
static let appPrimary = Color(hex: "FF6B6B")
static let appSecondary = Color(hex: "4ECDC4")
```

### Mock Data
Edit `Mock/MockData.swift` to add/modify sample data

## 🎯 Future Enhancements

- [ ] Real API integration
- [ ] Image upload to server
- [ ] Push notifications
- [ ] Social login (Apple, Google)
- [ ] Referral system
- [ ] Search with filters
- [ ] Favorites/bookmarks
- [ ] Receipt OCR for automatic item detection

## 📄 License

This is a sample project for demonstration purposes.

---

**Built with ❤️ using SwiftUI**
