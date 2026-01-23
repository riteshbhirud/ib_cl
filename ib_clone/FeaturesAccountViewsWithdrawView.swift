//
//  WithdrawView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct WithdrawView: View {
    @Bindable var viewModel: AccountViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: String = ""
    @State private var showingConfirmation = false
    @State private var showingSuccess = false
    @State private var showingError = false
    
    private var balance: Double {
        viewModel.user?.balance ?? 0
    }
    
    private var withdrawalAmount: Double {
        Double(amount) ?? 0
    }
    
    private var isValidAmount: Bool {
        withdrawalAmount >= 15.0 && withdrawalAmount <= balance
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.xl) {
                        // Current Balance
                        balanceSection
                        
                        // Amount Input
                        amountInputSection
                        
                        // Payment Method (placeholder)
                        paymentMethodSection
                        
                        // Info
                        infoSection
                    }
                    .padding(AppSpacing.lg)
                }
                
                // Withdraw Button
                VStack(spacing: 0) {
                    Divider()
                    
                    PrimaryButton(
                        title: "Request Withdrawal",
                        action: {
                            showingConfirmation = true
                        },
                        isDisabled: !isValidAmount
                    )
                    .padding(AppSpacing.lg)
                }
                .background(Color.adaptiveCard)
            }
            .background(Color.adaptiveBackground)
            .navigationTitle("Withdraw Funds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                "Confirm Withdrawal",
                isPresented: $showingConfirmation,
                titleVisibility: .visible
            ) {
                Button("Withdraw \(withdrawalAmount.asCurrency)", role: .none) {
                    Task {
                        do {
                            try await viewModel.requestWithdrawal(amount: withdrawalAmount)
                            showingSuccess = true
                        } catch {
                            showingError = true
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This amount will be sent to your PayPal account within 3-5 business days.")
            }
            .alert("Withdrawal Requested", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your withdrawal request has been submitted. Funds will be sent within 3-5 business days.")
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(viewModel.withdrawalError ?? "An error occurred")
            }
        }
    }
    
    // MARK: - Balance Section
    private var balanceSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Available Balance")
                .font(.appCallout(.medium))
                .foregroundColor(.adaptiveTextSecondary)
            
            Text(balance.asCurrency)
                .font(.appTitle1(.bold))
                .foregroundColor(.appCashback)
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.appCashback.opacity(0.1), Color.appSecondary.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(AppSpacing.cardCornerRadius)
    }
    
    // MARK: - Amount Input Section
    private var amountInputSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Withdrawal Amount")
                .font(.appHeadline(.semibold))
                .foregroundColor(.adaptiveTextPrimary)
            
            HStack {
                Text("$")
                    .font(.appTitle2(.bold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                TextField("0.00", text: $amount)
                    .font(.appTitle2(.bold))
                    .foregroundColor(.adaptiveTextPrimary)
                    .keyboardType(.decimalPad)
            }
            .padding(AppSpacing.lg)
            .background(Color.adaptiveCard)
            .cornerRadius(AppSpacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                    .stroke(isValidAmount ? Color.appSuccess : Color.gray.opacity(0.2), lineWidth: 2)
            )
            
            // Quick amounts
            HStack(spacing: AppSpacing.sm) {
                QuickAmountButton(amount: 15.0, currentAmount: $amount, isEnabled: balance >= 15.0)
                QuickAmountButton(amount: 25.0, currentAmount: $amount, isEnabled: balance >= 25.0)
                QuickAmountButton(amount: 50.0, currentAmount: $amount, isEnabled: balance >= 50.0)
                QuickAmountButton(title: "Max", amount: balance, currentAmount: $amount, isEnabled: true)
            }
            
            // Validation message
            if !amount.isEmpty {
                if withdrawalAmount < 15.0 {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "exclamationmark.circle.fill")
                        Text("Minimum withdrawal is $15.00")
                    }
                    .font(.appCaption1(.medium))
                    .foregroundColor(.appPrimary)
                } else if withdrawalAmount > balance {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "exclamationmark.circle.fill")
                        Text("Amount exceeds available balance")
                    }
                    .font(.appCaption1(.medium))
                    .foregroundColor(.appPrimary)
                } else {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Valid withdrawal amount")
                    }
                    .font(.appCaption1(.medium))
                    .foregroundColor(.appSuccess)
                }
            }
        }
    }
    
    // MARK: - Payment Method Section
    private var paymentMethodSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Payment Method")
                .font(.appHeadline(.semibold))
                .foregroundColor(.adaptiveTextPrimary)
            
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "p.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("PayPal")
                        .font(.appCallout(.semibold))
                        .foregroundColor(.adaptiveTextPrimary)
                    
                    Text(viewModel.user?.email ?? "")
                        .font(.appCaption1(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                }
                
                Spacer()
            }
            .padding(AppSpacing.lg)
            .background(Color.adaptiveCard)
            .cornerRadius(AppSpacing.cardCornerRadius)
        }
    }
    
    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.appSecondary)
                
                Text("Withdrawals are processed within 3-5 business days. You'll receive an email confirmation once your request is complete.")
                    .font(.appCallout(.regular))
                    .foregroundColor(.adaptiveTextSecondary)
            }
        }
        .padding(AppSpacing.lg)
        .background(Color.appSecondary.opacity(0.1))
        .cornerRadius(AppSpacing.cardCornerRadius)
    }
}

// MARK: - Quick Amount Button
struct QuickAmountButton: View {
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
            currentAmount = String(format: "%.2f", amount)
        }) {
            Text(title ?? "$\(Int(amount))")
                .font(.appCallout(.semibold))
                .foregroundColor(isEnabled ? .appPrimary : .gray)
                .padding(.vertical, AppSpacing.sm)
                .frame(maxWidth: .infinity)
                .background(isEnabled ? Color.appPrimary.opacity(0.1) : Color.gray.opacity(0.1))
                .cornerRadius(AppSpacing.radiusSmall)
        }
        .disabled(!isEnabled)
        .pressAnimation()
    }
}

#Preview {
    WithdrawView(viewModel: AccountViewModel())
}
