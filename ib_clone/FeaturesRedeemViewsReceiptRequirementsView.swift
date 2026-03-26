//
//  ReceiptRequirementsView.swift
//  ib_clone
//
//  Created by rb on 1/22/26.
//

import SwiftUI

struct ReceiptRequirementsView: View {
    let store: Store
    let onContinue: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    private var cutoffDate: Date {
        Calendar.current.date(byAdding: .day, value: -6, to: Date())!
    }
    
    private var formattedCutoffDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: cutoffDate)
    }
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            // Main Card
            VStack(spacing: 0) {
                // Header
                VStack(spacing: AppSpacing.md) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appPrimary.opacity(0.15), Color.appSecondary.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 36))
                            .foregroundColor(.appPrimary)
                    }
                    
                    VStack(spacing: AppSpacing.xs) {
                        Text("Receipt Requirements")
                            .font(.appTitle2(.bold))
                            .foregroundColor(.adaptiveTextPrimary)
                        
                        Text("Please ensure your receipt meets these criteria")
                            .font(.appCallout(.regular))
                            .foregroundColor(.adaptiveTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, AppSpacing.xxxl)
                .padding(.horizontal, AppSpacing.xl)
                
                // Requirements List
                VStack(spacing: AppSpacing.lg) {
                    RequirementRow(
                        icon: "building.2.fill",
                        iconColor: .appSecondary,
                        title: "Correct Retailer",
                        description: "Receipt must be from \(store.name)"
                    )
                    
                    RequirementRow(
                        icon: "calendar.badge.clock",
                        iconColor: .appSuccess,
                        title: "Recent Purchase",
                        description: "Receipt date must be after \(formattedCutoffDate)"
                    )
                    
                    RequirementRow(
                        icon: "barcode.viewfinder",
                        iconColor: .appPrimary,
                        title: "Clear Barcode",
                        description: "Barcode must be visible and scannable"
                    )
                    
                    RequirementRow(
                        icon: "list.bullet.rectangle",
                        iconColor: .appCashback,
                        title: "Items Visible",
                        description: "Purchased items must be clearly shown"
                    )
                }
                .padding(AppSpacing.xl)
                
                // Important Note
                HStack(alignment: .top, spacing: AppSpacing.md) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.appSecondary)
                        .font(.system(size: 20))
                    
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Important")
                            .font(.appCallout(.semibold))
                            .foregroundColor(.adaptiveTextPrimary)
                        
                        Text("Receipts that don't meet these requirements will be automatically rejected")
                            .font(.appCaption1(.regular))
                            .foregroundColor(.adaptiveTextSecondary)
                    }
                }
                .padding(AppSpacing.lg)
                .background(Color.appSecondary.opacity(0.08))
                .cornerRadius(AppSpacing.radiusMedium)
                .padding(.horizontal, AppSpacing.xl)
                
                // Buttons
                VStack(spacing: AppSpacing.md) {
                    PrimaryButton(
                        title: "I Understand, Continue",
                        action: {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onContinue()
                            }
                        }
                    )
                    
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.appCallout(.semibold))
                            .foregroundColor(.adaptiveTextSecondary)
                    }
                    .pressAnimation()
                }
                .padding(AppSpacing.xl)
                .padding(.bottom, AppSpacing.lg)
            }
            .background(Color.adaptiveBackground)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            .padding(AppSpacing.xl)
        }
    }
}

// MARK: - Requirement Row
struct RequirementRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(.appCallout(.semibold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                Text(description)
                    .font(.appCaption1(.regular))
                    .foregroundColor(.adaptiveTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    ReceiptRequirementsView(
        store: Store(name: "Walmart", logoUrl: nil, description: nil),
        onContinue: {}
    )
}
