//
//  SubmissionSuccessView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct SubmissionSuccessView: View {
    let totalCashback: Double
    var dismissFlow: (() -> Void)? = nil
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: AppSpacing.xxxl) {
            Spacer()
            
            // Success Animation
            ZStack {
                Circle()
                    .fill(Color.appSuccess.opacity(0.1))
                    .frame(width: 160, height: 160)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .opacity(isAnimating ? 0 : 1)
                
                Circle()
                    .fill(Color.appSuccess.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.appSuccess)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    isAnimating = true
                }
                
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
            
            // Success Message
            VStack(spacing: AppSpacing.lg) {
                Text("Submission Received!")
                    .font(.appTitle1(.bold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                VStack(spacing: AppSpacing.xs) {
                    Text("Total Cashback Pending")
                        .font(.appCallout(.medium))
                        .foregroundColor(.adaptiveTextSecondary)
                    
                    Text(totalCashback.asCurrency)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.appCashback)
                }
                .padding(.vertical, AppSpacing.lg)
                .padding(.horizontal, AppSpacing.xxxl)
                .background(Color.appSuccess.opacity(0.1))
                .cornerRadius(AppSpacing.radiusMedium)
                
                Text("We'll review your receipt within 24-48 hours and credit your account once approved.")
                    .font(.appCallout(.regular))
                    .foregroundColor(.adaptiveTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xxxl)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: AppSpacing.md) {
                PrimaryButton(
                    title: "View Activity",
                    action: {
                        appState.selectedTab = .activity
                        dismissFlow?()
                    },
                    style: .primary
                )
                
                PrimaryButton(
                    title: "Back to Home",
                    action: {
                        appState.selectedTab = .home
                        dismissFlow?()
                    },
                    style: .outline
                )
            }
            .padding(AppSpacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.adaptiveBackground)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    appState.selectedTab = .home
                    dismissFlow?()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.adaptiveTextPrimary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SubmissionSuccessView(totalCashback: 15.50)
            .environment(AppState.shared)
    }
}
