# WithdrawView UI Layout Guide

## Screen Structure (Top to Bottom)

```
┌────────────────────────────────────────┐
│  Navigation Bar                        │
│  ┌──────────────────────────────────┐  │
│  │ "Withdraw Funds"        [Close]  │  │
│  └──────────────────────────────────┘  │
├────────────────────────────────────────┤
│                                        │
│  ╔══════════════════════════════════╗  │
│  ║ 📊 Balance Overview Card         ║  │
│  ║  "Your Earnings"                 ║  │
│  ║  Track your cashback journey     ║  │
│  ║  ────────────────────────────    ║  │
│  ║                                  ║  │
│  ║  Current Balance | Lifetime      ║  │
│  ║     $124.50      |  $387.25      ║  │
│  ║  Available to    | Total earned  ║  │
│  ║    withdraw      |               ║  │
│  ╚══════════════════════════════════╝  │
│                                        │
│  Withdrawal Method                     │
│  ┌──────────────────────────────────┐  │
│  │ 🎁  Visa Gift Card    [Instant]  │  │
│  │     Choose from 150+ options     │  │
│  │     ⏰ Link sent within 24hrs   ✓│  │
│  └──────────────────────────────────┘  │
│                                        │
│  Withdrawal Amount                     │
│  ┌──────────────────────────────────┐  │
│  │  $  [Enter amount here...]       │  │
│  └──────────────────────────────────┘  │
│                                        │
│  [  $15  ] [  $25  ] [  $50  ] [ Max ]│
│                                        │
│  ✓ Valid withdrawal amount             │
│                                        │
│  ╔══════════════════════════════════╗  │
│  ║ ℹ️  How it works                 ║  │
│  ║                                  ║  │
│  ║ 1️⃣ Enter withdrawal amount      ║  │
│  ║ 2️⃣ We'll send you an email      ║  │
│  ║ 3️⃣ Choose from 150+ gift cards  ║  │
│  ║ 4️⃣ Receive gift card instantly  ║  │
│  ╚══════════════════════════════════╝  │
│                                        │
├────────────────────────────────────────┤
│  Bottom Action Bar                     │
│  ────────────────────────────────      │
│                                        │
│  You'll receive: $50.00 gift card      │
│                                        │
│  ┌──────────────────────────────────┐  │
│  │     Request Withdrawal           │  │
│  └──────────────────────────────────┘  │
└────────────────────────────────────────┘
```

## Success Overlay (After Withdrawal)

```
┌────────────────────────────────────────┐
│                                        │
│                                        │
│           ┌──────────────┐             │
│           │              │             │
│           │      ✓       │   (Green)   │
│           │              │             │
│           └──────────────┘             │
│                                        │
│      Withdrawal Requested!             │
│                                        │
│            $50.00                      │
│                                        │
│   We've received your withdrawal       │
│            request                     │
│                                        │
│   Check your email within 24 hours     │
│   to choose from 150+ gift card        │
│            options                     │
│                                        │
│   ┌──────────────────────────────┐    │
│   │ ✉️  user@example.com         │    │
│   └──────────────────────────────┘    │
│                                        │
│   ┌──────────────────────────────┐    │
│   │          Done                │    │
│   └──────────────────────────────┘    │
│                                        │
└────────────────────────────────────────┘
```

## Color Scheme

### Balance Overview Card
- Background: Gradient (cashback green → success green, 8% opacity)
- Border: Cashback green (20% opacity)
- Text: Primary (bold) and Secondary
- Shadow: Cashback green (10% opacity)

### Gift Card Option
- Background: Card color (white/dark)
- Border: Primary color (2px, selected state)
- Icon: Gradient circle (Primary → Secondary)
- Badge: Success green with white text
- Checkmark: Primary color

### Amount Input
- Border Colors:
  - Empty: Gray (20% opacity)
  - Valid: Success green
  - Invalid: Primary red
- Text: Bold, large (28pt)

### Quick Amount Buttons
- Background: Primary color (enabled) / Gray (disabled)
- Text: White (enabled) / Gray (disabled)
- Radius: Medium

### Info Banner
- Background: Secondary color (8% opacity)
- Icon: Secondary color
- Text: Primary and Secondary

### Bottom Bar
- Background: Card color
- Shadow: Black (10% opacity, upward)
- Button: Primary color with white text

### Success Overlay
- Background: Semi-transparent black overlay
- Card: Adaptive background
- Icon: Success green circle
- Text: Primary, Secondary, Cashback colors
- Shadow: Strong (30% opacity)

## Typography

- **Navigation Title**: App Headline
- **Card Titles**: App Callout (Medium)
- **Balance Amount**: System Bold 32pt
- **Section Headers**: App Headline (Semibold)
- **Amount Input**: System Bold 28pt
- **Body Text**: App Callout (Regular)
- **Captions**: App Caption1
- **Button**: App Headline (Semibold)

## Spacing

- Screen padding: Large (16-20px)
- Section spacing: XL (24-32px)
- Card padding: XL (24-32px)
- Element spacing: MD (12-16px)
- Small spacing: SM (8px)
- Tiny spacing: XS (4px)

## Interactions

1. **Balance Badge (Home Screen)**
   - Tap → Opens sheet
   - Haptic: Light impact
   - Animation: Scale to 0.97

2. **Amount Input**
   - Tap → Shows keyboard (decimal pad)
   - Type → Live validation
   - Border → Color changes based on validity

3. **Quick Amount Buttons**
   - Tap → Sets amount
   - Haptic: Light impact
   - Animation: Scale to 0.97
   - Disabled: Gray, no interaction

4. **Request Withdrawal Button**
   - Tap → Shows confirmation dialog
   - Disabled: Gray, no interaction
   - Loading: Shows spinner + "Processing..."
   - Haptic: Light impact

5. **Confirmation Dialog**
   - Confirm → Processes withdrawal
   - Cancel → Dismisses dialog

6. **Success Overlay**
   - Appears: Fade in + scale animation
   - Icon: Scales from 0.5 to 1.0
   - Done button → Dismisses + closes sheet

## States

### Loading States
- Initial: Normal
- Processing: Button shows "Processing..." with spinner
- Success: Shows success overlay
- Error: Shows alert dialog

### Validation States
- Empty: Neutral gray border
- Valid (≥$15, ≤balance): Green border, checkmark message
- Too Low (<$15): Red border, error message
- Too High (>balance): Red border, error message

### Button States
- Enabled: Primary color, active
- Disabled: Gray, no interaction
- Loading: Primary color with spinner
- Pressed: Scales to 0.97

## Animations

1. **Sheet Presentation**: Slide up from bottom
2. **Success Icon**: Spring animation (scale 0.5 → 1.0)
3. **Button Press**: Spring scale (1.0 → 0.97)
4. **Overlay**: Fade in + spring
5. **Border Color**: Smooth color transition
6. **Dismiss**: Fade out + slide down

## Accessibility

- All text uses system fonts (scales with Dynamic Type)
- Colors use adaptive system colors (dark mode support)
- Touch targets minimum 44x44 points
- Clear visual feedback for all interactions
- Validation messages announce state changes
- Haptic feedback for important actions

## Edge Cases Handled

1. **$0 Balance**: Max button disabled, all quick buttons disabled
2. **$10 Balance**: Shows error, can't withdraw
3. **$15 Balance**: Minimum met, can withdraw
4. **$14.99 entered**: Shows validation error
5. **$1000 entered (only $50 balance)**: Shows error
6. **Non-numeric input**: Filtered automatically
7. **Multiple decimals**: Prevented
8. **Cancel confirmation**: No action taken
9. **Network error**: Shows error alert
10. **Success then dismiss**: Balance updated in home screen
