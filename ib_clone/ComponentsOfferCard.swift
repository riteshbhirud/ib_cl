//
//  OfferCard.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct OfferCard: View {
    let offer: Offer
    let isInList: Bool
    let onAddToList: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Section
            ZStack(alignment: .topTrailing) {
                // Product Image — contained with light background
                Group {
                    if let imageUrl = offer.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Color.gray.opacity(0.06)
                                    .overlay(ProgressView())
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .padding(AppSpacing.md)
                            case .failure:
                                Color.gray.opacity(0.06)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(.system(size: 28))
                                            .foregroundColor(.gray.opacity(0.3))
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Color.gray.opacity(0.06)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 28))
                                    .foregroundColor(.gray.opacity(0.3))
                            )
                    }
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.04))
                
                // Badges Overlay
                VStack(alignment: .trailing, spacing: 3) {
                    if offer.expiringSoon == true {
                        HStack(spacing: 3) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 8, weight: .bold))
                            Text("Expiring")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.orange)
                        .cornerRadius(4)
                    }
                    
                    if let specialTag = offer.specialTag {
                        Text(specialTag)
                            .font(.system(size: 8, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.2, green: 0.8, blue: 0.5),
                                        Color(red: 0.1, green: 0.7, blue: 0.6)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(4)
                    }
                    
                    if offer.hasBonus == true {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 8, weight: .bold))
                            Text("BONUS")
                                .font(.system(size: 9, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.orange)
                        .cornerRadius(4)
                    }
                }
                .padding(6)
            }
            
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(height: 1)
            
            // Info Section
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(offer.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.adaptiveTextPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                CashbackBadge(amount: offer.cashback, size: .small)
                
                if let requirement = offer.purchaseRequirement {
                    HStack(spacing: 3) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 9))
                        Text(requirement)
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.adaptiveTextSecondary)
                }
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.sm)
            
            // Add/Remove Button
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    onAddToList()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: isInList ? "minus" : "plus")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(isInList ? Color.appPrimary.opacity(0.6) : Color.appPrimary)
                        .clipShape(Circle())
                    
                    Text(isInList ? "Remove" : "Add to List")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isInList ? .adaptiveTextSecondary : .appPrimary)
                    
                    Spacer()
                }
                .padding(.horizontal, AppSpacing.sm)
                .padding(.bottom, AppSpacing.sm)
            }
            .pressAnimation()
        }
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        .scaleEffect(isPressed ? 0.97 : 1.0)
    }
}

#Preview {
    let mockOffer = Offer(
        offerId: "test",
        slug: "tide-pods",
        name: "Tide PODS Laundry Detergent, 81ct",
        imageUrl: "tide",
        cashback: 3.50,
        details: "Get $3.50 back",
        specialTag: "FREE AFTER OFFER",
        purchaseRequirement: "Must buy 2",
        redemptionLimit: 2,
        expiringSoon: true,
        hasBonus: true
    )
    
    ScrollView {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            OfferCard(offer: mockOffer, isInList: false) {}
            OfferCard(offer: mockOffer, isInList: true) {}
        }
        .padding(.horizontal, 16)
    }
    .background(Color.adaptiveBackground)
}
