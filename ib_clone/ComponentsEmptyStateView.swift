//
//  EmptyStateView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.appSecondary.opacity(0.6))
            
            VStack(spacing: AppSpacing.sm) {
                Text(title)
                    .font(.appTitle3(.semibold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                Text(message)
                    .font(.appCallout(.regular))
                    .foregroundColor(.adaptiveTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xxxl)
            }
            
            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
                    .padding(.horizontal, AppSpacing.xxxl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.adaptiveBackground)
    }
}

#Preview {
    VStack {
        EmptyStateView(
            icon: "tray.fill",
            title: "Your List is Empty",
            message: "Start browsing stores and add offers to see them here!",
            actionTitle: "Browse Stores",
            action: {}
        )
    }
}
