//
//  LoadingView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .appPrimary))
                .scaleEffect(1.5)
            
            Text(message)
                .font(.appCallout(.medium))
                .foregroundColor(.adaptiveTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.adaptiveBackground)
    }
}

// MARK: - Skeleton Loading Views
struct SkeletonOfferCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .aspectRatio(1.0, contentMode: .fit)
                .shimmer(isLoading: true)
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                    .shimmer(isLoading: true)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                    .frame(width: 100)
                    .shimmer(isLoading: true)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 20)
                    .frame(width: 80)
                    .cornerRadius(6)
                    .shimmer(isLoading: true)
            }
            .padding(AppSpacing.sm)
        }
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

struct SkeletonStoreCard: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 60)
                .shimmer(isLoading: true)
            
            VStack(spacing: AppSpacing.xs) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                    .frame(width: 80)
                    .shimmer(isLoading: true)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 12)
                    .frame(width: 60)
                    .shimmer(isLoading: true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.md)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

struct SkeletonListRow: View {
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 60)
                .cornerRadius(AppSpacing.radiusSmall)
                .shimmer(isLoading: true)
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                    .shimmer(isLoading: true)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 14)
                    .frame(width: 100)
                    .shimmer(isLoading: true)
            }
            
            Spacer()
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 30)
                .cornerRadius(AppSpacing.radiusSmall)
                .shimmer(isLoading: true)
        }
        .padding(AppSpacing.md)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
    }
}

#Preview {
    VStack(spacing: 20) {
        LoadingView()
            .frame(height: 200)
        
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(0..<4) { _ in
                    SkeletonOfferCard()
                }
            }
            .padding()
        }
        .frame(height: 400)
    }
    .background(Color.adaptiveBackground)
}
