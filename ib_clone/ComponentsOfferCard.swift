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
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Image Section
            ZStack(alignment: .topTrailing) {
                // Product Image with AsyncImage from database
                Group {
                    if let imageUrl = offer.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .overlay(
                                        ProgressView()
                                    )
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .aspectRatio(1.0, contentMode: .fill)
                                    .clipped()
                            case .failure:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray.opacity(0.3))
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .aspectRatio(1.0, contentMode: .fit)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.3))
                            )
                    }
                }
                
                // Badges Overlay
                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    if offer.expiringSoon {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 10, weight: .bold))
                            Text("Expiring Soon")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            LinearGradient(
                                colors: [Color.orange, Color.orange.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(8)
                        .shadow(color: Color.orange.opacity(0.4), radius: 4, x: 0, y: 2)
                    }
                    
                    if let specialTag = offer.specialTag {
                        HStack(spacing: 5) {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 11, weight: .bold))
                            Text(specialTag)
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.8, blue: 0.5),  // Bright mint green
                                    Color(red: 0.1, green: 0.7, blue: 0.6)   // Emerald teal
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(8)
                        .shadow(color: Color.green.opacity(0.5), radius: 5, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    if offer.hasBonus {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10, weight: .bold))
                            Text("BONUS")
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.65, blue: 0.0),  // Golden orange
                                    Color(red: 1.0, green: 0.5, blue: 0.0)    // Bright orange
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(8)
                        .shadow(color: Color.orange.opacity(0.5), radius: 5, x: 0, y: 2)
                        .cornerRadius(6)
                    }
                }
                .padding(AppSpacing.sm)
            }
            
            // Info Section
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(offer.name)
                    .font(.appCallout(.medium))
                    .foregroundColor(.adaptiveTextPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                CashbackBadge(amount: offer.cashback, size: .small)
                
                if let requirement = offer.purchaseRequirement {
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 10))
                        Text(requirement)
                            .font(.appCaption2(.regular))
                    }
                    .foregroundColor(.adaptiveTextSecondary)
                }
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.bottom, AppSpacing.sm)
            
            // Add Button
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    onAddToList()
                }
            }) {
                HStack {
                    Image(systemName: isInList ? "checkmark" : "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(isInList ? Color.appSuccess : Color.appPrimary)
                        .clipShape(Circle())
                    
                    Text(isInList ? "Added" : "Add to List")
                        .font(.appFootnote(.semibold))
                        .foregroundColor(isInList ? .appSuccess : .appPrimary)
                    
                    Spacer()
                }
                .padding(AppSpacing.sm)
            }
            .pressAnimation()
        }
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .scaleEffect(isPressed ? 0.97 : 1.0)
    }
}

#Preview {
    let mockStore = MockData.shared.stores[0]
    let mockOffer = Offer(
        storeId: mockStore.id,
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
    
    return VStack {
        HStack(spacing: 16) {
            OfferCard(offer: mockOffer, isInList: false) {}
                .frame(width: 160)
            
            OfferCard(offer: mockOffer, isInList: true) {}
                .frame(width: 160)
        }
    }
    .padding()
    .background(Color.adaptiveBackground)
}
