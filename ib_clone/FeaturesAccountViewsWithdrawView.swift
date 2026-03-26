//
//  WithdrawView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct WithdrawView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingGiftCardFlow = false
    
    private var currentBalance: Double {
        appState.currentUser?.balance ?? 0
    }
    
    private var lifetimeEarnings: Double {
        appState.currentUser?.totalEarned ?? 0
    }
    
    private var canWithdraw: Bool {
        currentBalance > 0
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    // Balance Overview Card
                    balanceOverviewCard
                    
                    // Withdrawal Methods
                    withdrawalMethodsSection
                }
                .padding(AppSpacing.lg)
            }
            .background(Color.adaptiveBackground)
            .navigationTitle("Withdraw Funds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(.appCallout(.medium))
                    .foregroundColor(.appPrimary)
                }
            }
            .sheet(isPresented: $showingGiftCardFlow) {
                GiftCardWithdrawalView()
            }
        }
    }
    
    // MARK: - Balance Overview Card
    private var balanceOverviewCard: some View {
        VStack(spacing: AppSpacing.lg) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Your Earnings")
                        .font(.appCallout(.medium))
                        .foregroundColor(.adaptiveTextSecondary)
                    
                    Text("Track your cashback journey")
                        .font(.appCaption1(.regular))
                        .foregroundColor(.adaptiveTextSecondary.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 28))
                    .foregroundColor(.appCashback.opacity(0.6))
            }
            
            Divider()
            
            // Balance Stats
            HStack(spacing: 0) {
                // Current Balance
                VStack(spacing: AppSpacing.sm) {
                    VStack(spacing: AppSpacing.xs) {
                        Text("Current Balance")
                            .font(.appCaption1(.medium))
                            .foregroundColor(.adaptiveTextSecondary)
                        
                        Text(currentBalance.asCurrency)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.appCashback)
                    }
                    
                    Text("Available to withdraw")
                        .font(.appCaption2(.regular))
                        .foregroundColor(.adaptiveTextSecondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 1, height: 70)
                
                // Lifetime Earnings
                VStack(spacing: AppSpacing.sm) {
                    VStack(spacing: AppSpacing.xs) {
                        Text("Lifetime Earned")
                            .font(.appCaption1(.medium))
                            .foregroundColor(.adaptiveTextSecondary)
                        
                        Text(lifetimeEarnings.asCurrency)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.appSuccess)
                    }
                    
                    Text("Total cashback earned")
                        .font(.appCaption2(.regular))
                        .foregroundColor(.adaptiveTextSecondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(AppSpacing.xl)
        .background(
            LinearGradient(
                colors: [
                    Color.appCashback.opacity(0.08),
                    Color.appSuccess.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(AppSpacing.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius)
                .stroke(Color.appCashback.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.appCashback.opacity(0.1), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Withdrawal Methods Section
    private var withdrawalMethodsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Withdrawal Methods")
                .font(.appHeadline(.semibold))
                .foregroundColor(.adaptiveTextPrimary)
            
            // Gift Card Option
            Button(action: {
                if canWithdraw {
                    showingGiftCardFlow = true
                }
            }) {
                HStack(spacing: AppSpacing.lg) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: canWithdraw ? [Color.appPrimary, Color.appSecondary] : [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "giftcard.fill")
                            .font(.system(size: 24))
                            .foregroundColor(canWithdraw ? .white : .gray.opacity(0.5))
                    }
                    
                    // Info
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        HStack(spacing: AppSpacing.xs) {
                            Text("Gift Cards")
                                .font(.appCallout(.semibold))
                                .foregroundColor(canWithdraw ? .adaptiveTextPrimary : .adaptiveTextSecondary)
                            
                            if canWithdraw {
                                // Badge
                                Text("Popular")
                                    .font(.appCaption2(.bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.appSuccess)
                                    .cornerRadius(4)
                            }
                        }
                        
                        Text("Choose from 150+ gift card options")
                            .font(.appCaption1(.regular))
                            .foregroundColor(.adaptiveTextSecondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 10))
                            Text("Link sent within 24 hours")
                                .font(.appCaption1(.medium))
                        }
                        .foregroundColor(canWithdraw ? .appSecondary : .adaptiveTextSecondary.opacity(0.6))
                        
                        if !canWithdraw {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 10))
                                Text("Requires balance > $0")
                                    .font(.appCaption1(.medium))
                            }
                            .foregroundColor(.appPrimary)
                            .padding(.top, 2)
                        }
                    }
                    
                    Spacer()
                    
                    // Chevron
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(canWithdraw ? .adaptiveTextSecondary : .gray.opacity(0.3))
                }
                .padding(AppSpacing.lg)
                .background(Color.adaptiveCard)
                .cornerRadius(AppSpacing.cardCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius)
                        .stroke(canWithdraw ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(canWithdraw ? 0.05 : 0.02), radius: 8, x: 0, y: 2)
            }
            .disabled(!canWithdraw)
            .pressAnimation()
            
            // Coming Soon - Other Methods (Optional)
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(spacing: AppSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        HStack(spacing: AppSpacing.xs) {
                            Text("Bank Transfer")
                                .font(.appCallout(.semibold))
                                .foregroundColor(.adaptiveTextSecondary)
                            
                            Text("Coming Soon")
                                .font(.appCaption2(.bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.gray)
                                .cornerRadius(4)
                        }
                        
                        Text("Direct deposit to your bank account")
                            .font(.appCaption1(.regular))
                            .foregroundColor(.adaptiveTextSecondary.opacity(0.7))
                    }
                    
                    Spacer()
                }
                .padding(AppSpacing.lg)
                .background(Color.adaptiveCard.opacity(0.5))
                .cornerRadius(AppSpacing.cardCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Gift Card Withdrawal View
struct GiftCardWithdrawalView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: String = ""
    @State private var showingConfirmation = false
    @State private var isProcessing = false
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    private var currentBalance: Double {
        appState.currentUser?.balance ?? 0
    }
    
    private var withdrawalAmount: Double {
        Double(amount) ?? 0
    }
    
    private var isValidAmount: Bool {
        withdrawalAmount >= 15.0 && withdrawalAmount <= currentBalance
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: AppSpacing.xl) {
                            // Header Card
                            headerCard
                            
                            // Amount Input
                            amountInputSection
                            
                            // Info Banner
                            infoBanner
                        }
                        .padding(AppSpacing.lg)
                        .padding(.bottom, 100) // Space for button
                    }
                    
                    // Bottom Withdraw Button
                    bottomActionBar
                }
                .background(Color.adaptiveBackground)
                
                // Success overlay
                if showingSuccess {
                    successOverlay
                }
            }
            .navigationTitle("Gift Card Withdrawal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Back")
                        }
                        .foregroundColor(.appPrimary)
                    }
                }
            }
            .confirmationDialog(
                "Confirm Withdrawal",
                isPresented: $showingConfirmation,
                titleVisibility: .visible
            ) {
                Button("Withdraw \(withdrawalAmount.asCurrency)") {
                    processWithdrawal()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("You'll receive an email with a link to choose from 150+ gift card options within 24 hours.")
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: AppSpacing.lg) {
            // Icon and Title
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary.opacity(0.2), Color.appSecondary.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "giftcard.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.appPrimary)
                }
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Gift Cards")
                        .font(.appTitle3(.bold))
                        .foregroundColor(.adaptiveTextPrimary)
                    
                    Text("150+ options available")
                        .font(.appCallout(.medium))
                        .foregroundColor(.adaptiveTextSecondary)
                }
                
                Spacer()
            }
            
            // Available Balance
            VStack(spacing: AppSpacing.sm) {
                Text("Available Balance")
                    .font(.appCaption1(.medium))
                    .foregroundColor(.adaptiveTextSecondary)
                
                Text(currentBalance.asCurrency)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.appCashback)
            }
        }
        .padding(AppSpacing.xl)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Amount Input Section
    private var amountInputSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Withdrawal Amount")
                .font(.appHeadline(.semibold))
                .foregroundColor(.adaptiveTextPrimary)
            
            // Amount field
            HStack(spacing: AppSpacing.sm) {
                Text("$")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                TextField("0.00", text: $amount)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.adaptiveTextPrimary)
                    .keyboardType(.decimalPad)
                    .onChange(of: amount) { oldValue, newValue in
                        // Ensure valid decimal input
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        if filtered != newValue {
                            amount = filtered
                        }
                        // Only allow one decimal point
                        if filtered.filter({ $0 == "." }).count > 1 {
                            amount = oldValue
                        }
                    }
            }
            .padding(AppSpacing.lg)
            .background(Color.adaptiveCard)
            .cornerRadius(AppSpacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                    .stroke(
                        amount.isEmpty ? Color.gray.opacity(0.2) :
                        isValidAmount ? Color.appSuccess :
                        Color.appPrimary,
                        lineWidth: 2
                    )
            )
            
            // Quick amounts
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    WithdrawQuickAmountButton(amount: 15.0, currentAmount: $amount, isEnabled: currentBalance >= 15.0)
                    WithdrawQuickAmountButton(amount: 25.0, currentAmount: $amount, isEnabled: currentBalance >= 25.0)
                    WithdrawQuickAmountButton(amount: 50.0, currentAmount: $amount, isEnabled: currentBalance >= 50.0)
                    WithdrawQuickAmountButton(amount: 100.0, currentAmount: $amount, isEnabled: currentBalance >= 100.0)
                    WithdrawQuickAmountButton(title: "Max", amount: currentBalance, currentAmount: $amount, isEnabled: currentBalance >= 15.0)
                }
            }
            
            // Validation message
            if !amount.isEmpty {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: withdrawalAmount < 15.0 || withdrawalAmount > currentBalance ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                    
                    if withdrawalAmount < 15.0 {
                        Text("Minimum withdrawal is $15.00")
                    } else if withdrawalAmount > currentBalance {
                        Text("Amount exceeds available balance")
                    } else {
                        Text("Valid withdrawal amount")
                    }
                }
                .font(.appCaption1(.medium))
                .foregroundColor(isValidAmount ? .appSuccess : .appPrimary)
                .padding(.horizontal, AppSpacing.sm)
            }
        }
    }
    
    // MARK: - Info Banner
    private var infoBanner: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(alignment: .top, spacing: AppSpacing.md) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.appSecondary)
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("How it works")
                        .font(.appCallout(.semibold))
                        .foregroundColor(.adaptiveTextPrimary)
                    
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        WithdrawInfoRow(icon: "1.circle.fill", text: "Enter withdrawal amount (min. $15)")
                        WithdrawInfoRow(icon: "2.circle.fill", text: "We'll send you an email within 24 hours")
                        WithdrawInfoRow(icon: "3.circle.fill", text: "Choose from 150+ gift card options")
                        WithdrawInfoRow(icon: "4.circle.fill", text: "Receive your gift card instantly")
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(Color.appSecondary.opacity(0.08))
        .cornerRadius(AppSpacing.cardCornerRadius)
    }
    
    // MARK: - Bottom Action Bar
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            VStack(spacing: AppSpacing.sm) {
                if !amount.isEmpty && isValidAmount {
                    HStack {
                        Text("You'll receive:")
                            .font(.appCallout(.medium))
                            .foregroundColor(.adaptiveTextSecondary)
                        
                        Spacer()
                        
                        Text(withdrawalAmount.asCurrency)
                            .font(.appTitle3(.bold))
                            .foregroundColor(.appCashback)
                        
                        Text("gift card")
                            .font(.appCallout(.medium))
                            .foregroundColor(.adaptiveTextSecondary)
                    }
                }
                
                PrimaryButton(
                    title: isProcessing ? "Processing..." : "Request Withdrawal",
                    action: {
                        showingConfirmation = true
                    },
                    isLoading: isProcessing,
                    isDisabled: !isValidAmount || isProcessing
                )
            }
            .padding(AppSpacing.lg)
        }
        .background(Color.adaptiveCard)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -2)
    }
    
    // MARK: - Success Overlay
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.xl) {
                // Success Icon
                ZStack {
                    Circle()
                        .fill(Color.appSuccess)
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(showingSuccess ? 1 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showingSuccess)
                
                VStack(spacing: AppSpacing.md) {
                    Text("Withdrawal Requested!")
                        .font(.appTitle2(.bold))
                        .foregroundColor(.adaptiveTextPrimary)
                    
                    Text(withdrawalAmount.asCurrency)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.appCashback)
                    
                    VStack(spacing: AppSpacing.xs) {
                        Text("We've received your withdrawal request")
                            .font(.appCallout(.medium))
                            .foregroundColor(.adaptiveTextSecondary)
                            .multilineTextAlignment(.center)
                        
                        Text("Check your email within 24 hours to choose from 150+ gift card options")
                            .font(.appCallout(.regular))
                            .foregroundColor(.adaptiveTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
                
                // Email badge
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.appSecondary)
                    Text(appState.currentUser?.email ?? "your email")
                        .font(.appCallout(.semibold))
                        .foregroundColor(.adaptiveTextPrimary)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .background(Color.adaptiveCard)
                .cornerRadius(AppSpacing.radiusMedium)
                
                // Done button
                Button(action: {
                    withAnimation {
                        showingSuccess = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                    }
                }) {
                    Text("Done")
                        .font(.appHeadline(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.appPrimary)
                        .cornerRadius(AppSpacing.buttonCornerRadius)
                }
                .padding(.horizontal, AppSpacing.xl)
                .padding(.top, AppSpacing.md)
            }
            .padding(AppSpacing.xl)
            .background(Color.adaptiveBackground)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            .padding(AppSpacing.xl)
        }
        .transition(.opacity)
    }
    
    // MARK: - Process Withdrawal
    private func processWithdrawal() {
        guard isValidAmount else { return }
        
        isProcessing = true
        
        Task {
            do {
                // Call AppState method to process withdrawal
                try await appState.requestWithdrawal(amount: withdrawalAmount)
                
                // Success - show overlay
                await MainActor.run {
                    isProcessing = false
                    withAnimation(.spring(response: 0.5)) {
                        showingSuccess = true
                    }
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
}

// MARK: - Withdraw Quick Amount Button
private struct WithdrawQuickAmountButton: View {
    var title: String?
    let amount: Double
    @Binding var currentAmount: String
    let isEnabled: Bool
    
    init(title: String? = nil, amount: Double, currentAmount: Binding<String>, isEnabled: Bool) {
        self.title = title
        self.amount = amount
        self._currentAmount = currentAmount
        self.isEnabled = isEnabled
    }
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            currentAmount = String(format: "%.2f", amount)
        }) {
            Text(title ?? "$\(Int(amount))")
                .font(.appCallout(.semibold))
                .foregroundColor(isEnabled ? .white : .gray)
                .padding(.vertical, AppSpacing.md)
                .padding(.horizontal, AppSpacing.lg)
                .background(isEnabled ? Color.appPrimary : Color.gray.opacity(0.2))
                .cornerRadius(AppSpacing.radiusMedium)
        }
        .disabled(!isEnabled)
        .pressAnimation()
    }
}

// MARK: - Withdraw Info Row
private struct WithdrawInfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.appSecondary)
                .frame(width: 16)
            
            Text(text)
                .font(.appCaption1(.regular))
                .foregroundColor(.adaptiveTextSecondary)
        }
    }
}

#Preview {
    WithdrawView()
        .environment(AppState.shared)
}
