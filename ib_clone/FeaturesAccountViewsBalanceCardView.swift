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
        user?.canWithdraw ?? false
    }
    
    private var amountNeeded: Double {
        user?.amountNeededToWithdraw ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            // Balance Display
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Current Balance")
                    .font(.appCallout(.medium))
                    .foregroundColor(.white.opacity(0.9))
                
                Text(balance.asCurrency)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Withdrawal Info/Button
            if canWithdraw {
                PrimaryButton(
                    title: "Withdraw Funds",
                    action: onWithdrawTapped,
                    style: .secondary
                )
                
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.appSuccess)
                    
                    Text("Ready to withdraw!")
                        .font(.appCallout(.medium))
                        .foregroundColor(.white)
                }
            } else {
                VStack(spacing: AppSpacing.md) {
                    // Progress Bar
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        HStack {
                            Text("Progress to $15 minimum")
                                .font(.appCaption1(.medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Spacer()
                            
                            Text("\(amountNeeded.asCurrency) more")
                                .font(.appCaption1(.semibold))
                                .foregroundColor(.white)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 8)
                                    .cornerRadius(4)
                                
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: geometry.size.width * (balance / 15.0), height: 8)
                                    .cornerRadius(4)
                            }
                        }
                        .frame(height: 8)
                    }
                    
                    Text("You'll be able to withdraw once you reach $15.00")
                        .font(.appCaption1(.regular))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(AppSpacing.xl)
        .background(
            LinearGradient(
                colors: [Color.appSecondary, Color.appSecondary.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(AppSpacing.radiusLarge)
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
