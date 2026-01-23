//
//  SubmissionDetailView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct SubmissionDetailView: View {
    let submission: Submission
    @State private var showingReceiptImage = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                // Receipt Image
                receiptSection
                
                // Status Card
                statusCard
                
                // Store Info
                storeInfo
                
                // Items List
                if let items = submission.items, !items.isEmpty {
                    itemsList(items)
                }
                
                // Summary
                summaryCard
            }
            .padding(AppSpacing.lg)
        }
        .background(Color.adaptiveBackground)
        .navigationTitle("Submission Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Receipt Section
    private var receiptSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Receipt")
                .font(.appHeadline(.semibold))
                .foregroundColor(.adaptiveTextPrimary)
            
            Button(action: {
                showingReceiptImage = true
            }) {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .aspectRatio(3/4, contentMode: .fit)
                    .cornerRadius(AppSpacing.radiusMedium)
                    .overlay(
                        VStack(spacing: AppSpacing.sm) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("Tap to view")
                                .font(.appCallout(.medium))
                                .foregroundColor(.adaptiveTextSecondary)
                        }
                    )
            }
            .pressAnimation()
        }
        .padding(AppSpacing.lg)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Status Card
    private var statusCard: some View {
        VStack(spacing: AppSpacing.lg) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: submission.status.iconName)
                    .font(.system(size: 32))
                    .foregroundColor(submission.status.color)
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Status")
                        .font(.appCaption1(.medium))
                        .foregroundColor(.adaptiveTextSecondary)
                    
                    Text(submission.status.displayName)
                        .font(.appTitle3(.bold))
                        .foregroundColor(.adaptiveTextPrimary)
                }
                
                Spacer()
            }
            
            if submission.status == .approved {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.appSuccess)
                    
                    Text("Cashback credited to your account")
                        .font(.appCallout(.medium))
                        .foregroundColor(.appSuccess)
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.appSuccess.opacity(0.1))
                .cornerRadius(AppSpacing.radiusSmall)
            }
            
            if submission.status == .rejected, let reason = submission.rejectionReason {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.appPrimary)
                        
                        Text("Rejection Reason")
                            .font(.appCallout(.semibold))
                            .foregroundColor(.appPrimary)
                    }
                    
                    Text(reason)
                        .font(.appCallout(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.appPrimary.opacity(0.1))
                .cornerRadius(AppSpacing.radiusSmall)
            }
        }
        .padding(AppSpacing.lg)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Store Info
    private var storeInfo: some View {
        HStack(spacing: AppSpacing.md) {
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "building.2.fill")
                        .foregroundColor(.appSecondary)
                )
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(submission.store?.name ?? "Unknown Store")
                    .font(.appHeadline(.semibold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                Text("Submitted \(submission.submittedAt.formatted)")
                    .font(.appCaption1(.regular))
                    .foregroundColor(.adaptiveTextSecondary)
                
                if let reviewedAt = submission.reviewedAt {
                    Text("Reviewed \(reviewedAt.formatted)")
                        .font(.appCaption1(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                }
            }
            
            Spacer()
        }
        .padding(AppSpacing.lg)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Items List
    private func itemsList(_ items: [SubmissionItem]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Items (\(items.count))")
                .font(.appHeadline(.semibold))
                .foregroundColor(.adaptiveTextPrimary)
                .padding(.horizontal, AppSpacing.lg)
            
            VStack(spacing: AppSpacing.sm) {
                ForEach(items) { item in
                    SubmissionItemRow(item: item)
                }
            }
        }
        .padding(.vertical, AppSpacing.lg)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text("Total Cashback")
                    .font(.appCallout(.medium))
                    .foregroundColor(.adaptiveTextSecondary)
                
                Spacer()
                
                Text(submission.totalCashback.asCurrency)
                    .font(.appTitle2(.bold))
                    .foregroundColor(.appCashback)
            }
        }
        .padding(AppSpacing.xl)
        .background(
            LinearGradient(
                colors: [Color.appCashback.opacity(0.1), Color.appSecondary.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Submission Item Row
struct SubmissionItemRow: View {
    let item: SubmissionItem
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 50, height: 50)
                .cornerRadius(AppSpacing.radiusSmall)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.gray.opacity(0.3))
                        .font(.system(size: 20))
                )
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(item.offerName)
                    .font(.appCallout(.medium))
                    .foregroundColor(.adaptiveTextPrimary)
                    .lineLimit(2)
                
                HStack(spacing: AppSpacing.xs) {
                    Text("\(item.cashbackPerItem.asCurrency) × \(item.quantity)")
                        .font(.appCaption1(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                }
            }
            
            Spacer()
            
            Text(item.totalCashback.asCurrency)
                .font(.appCallout(.semibold))
                .foregroundColor(.appCashback)
        }
        .padding(AppSpacing.lg)
    }
}

#Preview {
    NavigationStack {
        SubmissionDetailView(
            submission: MockData.shared.generateSubmissions(userId: UUID())[0]
        )
    }
}
