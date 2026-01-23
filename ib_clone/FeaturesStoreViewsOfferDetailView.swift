//
//  OfferDetailView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct OfferDetailView: View {
    let offer: Offer
    @Environment(AppState.self) private var appState
    @State private var quantity: Int = 1
    @Environment(\.dismiss) private var dismiss
    
    private var isInList: Bool {
        appState.isOfferInList(offer.id)
    }
    
    private var currentQuantityInList: Int {
        appState.userListItems.first(where: { $0.offerId == offer.id })?.quantity ?? 0
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    // Large Product Image
                    imageSection
                    
                    // Offer Details Card
                    detailsCard
                }
                .padding(.bottom, 100) // Space for bottom bar
            }
            
            // Bottom Action Bar
            bottomActionBar
        }
        .background(Color.adaptiveBackground)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            quantity = max(1, currentQuantityInList)
        }
    }
    
    // MARK: - Image Section
    private var imageSection: some View {
        ZStack(alignment: .topTrailing) {
            // Large Product Image with AsyncImage from database
            Group {
                if let imageUrl = offer.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 350)
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    ProgressView()
                                        .scaleEffect(1.5)
                                )
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 350)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.05))
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 350)
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 80))
                                        .foregroundColor(.gray.opacity(0.3))
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 350)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 80))
                                .foregroundColor(.gray.opacity(0.3))
                        )
                }
            }
            .clipped()
            .overlay(
                // Gradient overlay at bottom for badges visibility
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Badges
            VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                if offer.expiringSoon {
                    badgeView(
                        icon: "clock.fill",
                        text: "Expiring Soon",
                        color: .appWarning
                    )
                }
                
                if let specialTag = offer.specialTag {
                    badgeView(
                        text: specialTag,
                        color: .appSuccess
                    )
                }
                
                if offer.hasBonus {
                    badgeView(
                        icon: "star.fill",
                        text: "BONUS",
                        color: .appSecondary
                    )
                }
            }
            .padding(AppSpacing.lg)
        }
    }
    
    private func badgeView(icon: String? = nil, text: String, color: Color) -> some View {
        HStack(spacing: 5) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
            }
            Text(text)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Group {
                if text.contains("FREE") || text.contains("Free") {
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.8, blue: 0.5),
                            Color(red: 0.1, green: 0.7, blue: 0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else if text == "BONUS" {
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.65, blue: 0.0),
                            Color(red: 1.0, green: 0.5, blue: 0.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    LinearGradient(
                        colors: [color, color.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
        )
        .cornerRadius(10)
        .shadow(color: color.opacity(0.5), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Details Card
    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            // Title and Cashback
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text(offer.name)
                    .font(.appTitle2(.bold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                CashbackBadge(amount: offer.cashback, size: .large)
            }
            
            // Info Items
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                if let requirement = offer.purchaseRequirement {
                    infoRow(
                        icon: "cart.fill",
                        title: "Purchase Requirement",
                        value: requirement
                    )
                }
                
                infoRow(
                    icon: "repeat",
                    title: "Redemption Limit",
                    value: "\(offer.redemptionLimit) per receipt"
                )
                
                if let expiresAt = offer.expiresAt {
                    infoRow(
                        icon: "calendar",
                        title: "Expires",
                        value: expiresAt.formatted
                    )
                }
            }
            
            Divider()
            
            // Offer Details
            if let offerDetail = offer.offerDetail {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Offer Details")
                        .font(.appHeadline(.semibold))
                        .foregroundColor(.adaptiveTextPrimary)
                    
                    Text(offerDetail)
                        .font(.appCallout(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                        .lineSpacing(4)
                }
            }
            
            if let details = offer.details {
                Text(details)
                    .font(.appCallout(.regular))
                    .foregroundColor(.adaptiveTextSecondary)
            }
        }
        .padding(AppSpacing.xl)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.radiusLarge, corners: [.topLeft, .topRight])
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: -5)
        .offset(y: -20)
    }
    
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.appSecondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appCaption1(.medium))
                    .foregroundColor(.adaptiveTextSecondary)
                
                Text(value)
                    .font(.appCallout(.semibold))
                    .foregroundColor(.adaptiveTextPrimary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Bottom Action Bar
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: AppSpacing.lg) {
                // Quantity Selector
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Quantity")
                        .font(.appCaption1(.medium))
                        .foregroundColor(.adaptiveTextSecondary)
                    
                    QuantitySelector(
                        quantity: $quantity,
                        minimum: 1,
                        maximum: offer.redemptionLimit,
                        size: .medium
                    )
                }
                
                Spacer()
                
                // Total Cashback
                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    Text("Total Cashback")
                        .font(.appCaption1(.medium))
                        .foregroundColor(.adaptiveTextSecondary)
                    
                    Text((offer.cashback * Double(quantity)).asCurrency)
                        .font(.appTitle3(.bold))
                        .foregroundColor(.appCashback)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            
            // Add/Update Button
            PrimaryButton(
                title: isInList ? "Update List" : "Add to List",
                action: {
                    if isInList {
                        if let item = appState.userListItems.first(where: { $0.offerId == offer.id }) {
                            appState.updateQuantity(itemId: item.id, quantity: quantity)
                        }
                    } else {
                        appState.addToList(offer: offer, quantity: quantity)
                    }
                    dismiss()
                }
            )
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.lg)
        }
        .background(Color.adaptiveCard)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -2)
    }
}

#Preview {
    NavigationStack {
        OfferDetailView(
            offer: MockData.shared.generateOffers()[0]
        )
        .environment(AppState.shared)
    }
}
