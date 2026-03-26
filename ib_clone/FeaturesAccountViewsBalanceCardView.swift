//
//  BalanceCardView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct BalanceCardView: View {
    let user: User?
    let onWithdrawTapped: () -> Void
    
    private var balance: Double {
        user?.balance ?? 0
    }
    
    private var canWithdraw: Bool {
        balance > 0
    }
    
    private var amountNeeded: Double {
        max(0, 15.0 - balance)
    }
    
    private var progressToMinimum: Double {
        min(balance / 15.0, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            // Balance Display
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Current Balance")
                    .font(.appCallout(.medium))
                    .foregroundColor(.white.opacity(0.9))
                
                Text(balance.asCurrency)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Progress to $15 (only show if less than $15)
            if balance < 15.0 {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack {
                        Text("Progress to $15 minimum")
                            .font(.appCaption1(.medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                        
                        Text(amountNeeded > 0 ? "\(amountNeeded.asCurrency) to go" : "Ready!")
                            .font(.appCaption1(.semibold))
                            .foregroundColor(.white)
                    }
                    
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.25))
                                .frame(height: 10)
                            
                            // Progress
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white, Color.white.opacity(0.9)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progressToMinimum, height: 10)
                        }
                    }
                    .frame(height: 10)
                }
            }
            
            // Status Message
            if balance >= 15.0 {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.appSuccess)
                        .font(.system(size: 16))
                    
                    Text("Ready to withdraw!")
                        .font(.appCallout(.medium))
                        .foregroundColor(.white)
                }
            } else if balance > 0 {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 14))
                    
                    Text("Minimum $15 to withdraw as gift card")
                        .font(.appCaption1(.regular))
                        .foregroundColor(.white.opacity(0.8))
                }
            } else {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 14))
                    
                    Text("Start earning cashback to unlock withdrawals")
                        .font(.appCaption1(.regular))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Withdraw Button (always visible, enabled/disabled based on balance)
            Button(action: {
                if canWithdraw {
                    onWithdrawTapped()
                }
            }) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: canWithdraw ? "arrow.down.circle.fill" : "lock.fill")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Withdraw")
                        .font(.appHeadline(.semibold))
                }
                .foregroundColor(canWithdraw ? Color.appSecondary : Color.white.opacity(0.4))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    canWithdraw ?
                    Color.white :
                    Color.white.opacity(0.15)
                )
                .cornerRadius(AppSpacing.buttonCornerRadius)
                .shadow(
                    color: canWithdraw ? Color.black.opacity(0.1) : Color.clear,
                    radius: canWithdraw ? 8 : 0,
                    x: 0,
                    y: canWithdraw ? 4 : 0
                )
            }
            .disabled(!canWithdraw)
            .pressAnimation()
        }
        .padding(AppSpacing.xl)
        .background(
            LinearGradient(
                colors: [Color.appSecondary, Color.appSecondary.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.appSecondary.opacity(0.3), radius: 15, x: 0, y: 5)
    }
}

#Preview {
    VStack(spacing: 20) {
        BalanceCardView(
            user: User(name: "Test", email: "test@example.com", balance: 24.50),
            onWithdrawTapped: {}
        )
        .padding()
        
        BalanceCardView(
            user: User(name: "Test", email: "test@example.com", balance: 8.25),
            onWithdrawTapped: {}
        )
        .padding()
    }
    .background(Color.adaptiveBackground)
}
