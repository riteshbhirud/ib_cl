//
//  StoreCard.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct StoreCard: View {
    let store: Store
    var isFeatured: Bool = false
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            // Logo with AsyncImage from database
            Group {
                if let logoUrl = store.logoUrl, let url = URL(string: logoUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: isFeatured ? 80 : 60, height: isFeatured ? 80 : 60)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: isFeatured ? 80 : 60, height: isFeatured ? 80 : 60)
                                .clipShape(Circle())
                        case .failure:
                            // Fallback icon
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: isFeatured ? 80 : 60, height: isFeatured ? 80 : 60)
                                .overlay(
                                    Image(systemName: "building.2.fill")
                                        .font(.system(size: isFeatured ? 32 : 24))
                                        .foregroundColor(.appSecondary)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    // Default icon if no URL
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: isFeatured ? 80 : 60, height: isFeatured ? 80 : 60)
                        .overlay(
                            Image(systemName: "building.2.fill")
                                .font(.system(size: isFeatured ? 32 : 24))
                                .foregroundColor(.appSecondary)
                        )
                }
            }
            
            // Store Info
            VStack(spacing: AppSpacing.xs) {
                Text(store.name)
                    .font(isFeatured ? .appHeadline(.semibold) : .appCallout(.semibold))
                    .foregroundColor(.adaptiveTextPrimary)
                    .lineLimit(1)
                
                if let count = store.offerCount {
                    Text("\(count) offers")
                        .font(.appCaption1(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(isFeatured ? AppSpacing.lg : AppSpacing.md)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .pressAnimation()
    }
}

#Preview {
    let mockStore = MockData.shared.stores[0]
    
    return VStack(spacing: 20) {
        HStack(spacing: 16) {
            StoreCard(store: mockStore)
                .frame(width: 150, height: 150)
            
            StoreCard(store: mockStore, isFeatured: true)
                .frame(width: 180, height: 180)
        }
    }
    .padding()
    .background(Color.adaptiveBackground)
}
