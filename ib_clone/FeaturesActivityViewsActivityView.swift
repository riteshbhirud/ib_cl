//
//  ActivityView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct ActivityView: View {
    @State private var viewModel = ActivityViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segment Picker
                segmentPicker
                
                // Status Filter
                if viewModel.selectedSegment == .redemptions {
                    redemptionFilter
                } else {
                    withdrawalFilter
                }
                
                // Content
                if viewModel.selectedSegment == .redemptions {
                    if viewModel.submissions.isEmpty {
                        redemptionEmptyState
                    } else {
                        submissionsList
                    }
                } else {
                    if viewModel.withdrawals.isEmpty {
                        withdrawalEmptyState
                    } else {
                        withdrawalsList
                    }
                }
            }
            .background(Color.adaptiveBackground)
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Segment Picker
    private var segmentPicker: some View {
        HStack(spacing: 0) {
            ForEach(ActivityViewModel.ActivitySegment.allCases, id: \.self) { segment in
                let count = segment == .redemptions
                    ? viewModel.pendingCount + viewModel.approvedCount + viewModel.rejectedCount
                    : viewModel.totalWithdrawalsCount
                
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.selectedSegment = segment
                    }
                } label: {
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: segment == .redemptions ? "receipt.fill" : "arrow.up.circle.fill")
                                .font(.system(size: 13))
                            Text(segment.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                            
                            if count > 0 {
                                Text("\(count)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(viewModel.selectedSegment == segment ? Color.appPrimary : Color.gray.opacity(0.4))
                                    .clipShape(Capsule())
                            }
                        }
                        .foregroundColor(viewModel.selectedSegment == segment ? .appPrimary : .adaptiveTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        
                        Rectangle()
                            .fill(viewModel.selectedSegment == segment ? Color.appPrimary : Color.clear)
                            .frame(height: 2.5)
                            .cornerRadius(2)
                    }
                }
            }
        }
        .background(Color.adaptiveCard)
    }
    
    // MARK: - Redemption Filter
    private var redemptionFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.md) {
                StatusFilterButton(
                    title: "All",
                    count: viewModel.pendingCount + viewModel.approvedCount + viewModel.rejectedCount,
                    isSelected: viewModel.selectedSubmissionFilter == nil,
                    action: {
                        withAnimation {
                            viewModel.selectedSubmissionFilter = nil
                        }
                    }
                )
                
                StatusFilterButton(
                    title: "Pending",
                    count: viewModel.pendingCount,
                    color: .appWarning,
                    isSelected: viewModel.selectedSubmissionFilter == .pending,
                    action: {
                        withAnimation {
                            viewModel.selectedSubmissionFilter = .pending
                        }
                    }
                )
                
                StatusFilterButton(
                    title: "Approved",
                    count: viewModel.approvedCount,
                    color: .appSuccess,
                    isSelected: viewModel.selectedSubmissionFilter == .approved,
                    action: {
                        withAnimation {
                            viewModel.selectedSubmissionFilter = .approved
                        }
                    }
                )
                
                StatusFilterButton(
                    title: "Rejected",
                    count: viewModel.rejectedCount,
                    color: .appPrimary,
                    isSelected: viewModel.selectedSubmissionFilter == .rejected,
                    action: {
                        withAnimation {
                            viewModel.selectedSubmissionFilter = .rejected
                        }
                    }
                )
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
        }
        .background(Color.adaptiveCard)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Withdrawal Filter
    private var withdrawalFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.md) {
                StatusFilterButton(
                    title: "All",
                    count: viewModel.totalWithdrawalsCount,
                    isSelected: viewModel.selectedWithdrawalFilter == nil,
                    action: {
                        withAnimation {
                            viewModel.selectedWithdrawalFilter = nil
                        }
                    }
                )
                
                StatusFilterButton(
                    title: "In Progress",
                    count: viewModel.withdrawalPendingCount,
                    color: .appWarning,
                    isSelected: viewModel.selectedWithdrawalFilter == .pending,
                    action: {
                        withAnimation {
                            viewModel.selectedWithdrawalFilter = .pending
                        }
                    }
                )
                
                StatusFilterButton(
                    title: "Completed",
                    count: viewModel.withdrawalCompletedCount,
                    color: .appSuccess,
                    isSelected: viewModel.selectedWithdrawalFilter == .completed,
                    action: {
                        withAnimation {
                            viewModel.selectedWithdrawalFilter = .completed
                        }
                    }
                )
                
                StatusFilterButton(
                    title: "Failed",
                    count: viewModel.withdrawalFailedCount,
                    color: .appPrimary,
                    isSelected: viewModel.selectedWithdrawalFilter == .failed,
                    action: {
                        withAnimation {
                            viewModel.selectedWithdrawalFilter = .failed
                        }
                    }
                )
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
        }
        .background(Color.adaptiveCard)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Submissions List
    private var submissionsList: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.md) {
                ForEach(viewModel.submissions) { submission in
                    NavigationLink(value: submission) {
                        SubmissionCard(submission: submission)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(AppSpacing.lg)
        }
        .navigationDestination(for: Submission.self) { submission in
            SubmissionDetailView(submission: submission)
        }
    }
    
    // MARK: - Withdrawals List
    private var withdrawalsList: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.md) {
                ForEach(viewModel.withdrawals) { withdrawal in
                    WithdrawalCard(withdrawal: withdrawal)
                }
            }
            .padding(AppSpacing.lg)
        }
    }
    
    // MARK: - Empty States
    private var redemptionEmptyState: some View {
        EmptyStateView(
            icon: "receipt.fill",
            title: "No Submissions",
            message: "Your submission history will appear here once you start redeeming offers"
        )
    }
    
    private var withdrawalEmptyState: some View {
        EmptyStateView(
            icon: "arrow.up.circle.fill",
            title: "No Withdrawals",
            message: "Your withdrawal history will appear here once you cash out your earnings"
        )
    }
}

// MARK: - Status Filter Button
struct StatusFilterButton: View {
    let title: String
    let count: Int
    var color: Color = .appPrimary
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            VStack(spacing: AppSpacing.xs) {
                Text("\(count)")
                    .font(.appTitle3(.bold))
                    .foregroundColor(isSelected ? color : .adaptiveTextPrimary)
                
                Text(title)
                    .font(.appCaption1(.medium))
                    .foregroundColor(isSelected ? color : .adaptiveTextSecondary)
            }
            .frame(minWidth: 80)
            .padding(.vertical, AppSpacing.md)
            .padding(.horizontal, AppSpacing.lg)
            .background(isSelected ? color.opacity(0.1) : Color.clear)
            .cornerRadius(AppSpacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
        .pressAnimation()
    }
}

// MARK: - Submission Card
struct SubmissionCard: View {
    let submission: Submission
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                // Store Logo from DB
                Group {
                    if let logoUrl = submission.store?.logoUrl, let url = URL(string: logoUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 44, height: 44)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 44, height: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: 11))
                            case .failure:
                                submissionStoreFallback
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        submissionStoreFallback
                    }
                }
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(submission.store?.name ?? "Unknown Store")
                        .font(.appHeadline(.semibold))
                        .foregroundColor(.adaptiveTextPrimary)
                    
                    Text(submission.submittedAt.relativeTime)
                        .font(.appCaption1(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                }
                
                Spacer()
                
                // Status Badge
                HStack(spacing: 4) {
                    Image(systemName: submission.status.iconName)
                        .font(.system(size: 12))
                    Text(submission.status.displayName)
                        .font(.appCaption1(.semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
                .background(submission.status.color)
                .cornerRadius(AppSpacing.radiusSmall)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Total Cashback")
                        .font(.appCaption1(.medium))
                        .foregroundColor(.adaptiveTextSecondary)
                    
                    Text(submission.totalCashback.asCurrency)
                        .font(.appTitle3(.bold))
                        .foregroundColor(.appCashback)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    Text("Items")
                        .font(.appCaption1(.medium))
                        .foregroundColor(.adaptiveTextSecondary)
                    
                    Text("\(submission.items?.count ?? 0)")
                        .font(.appTitle3(.bold))
                        .foregroundColor(.adaptiveTextPrimary)
                }
            }
            
            if submission.status == .rejected, let reason = submission.rejectionReason {
                HStack(alignment: .top, spacing: AppSpacing.sm) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.appPrimary)
                        .font(.system(size: 14))
                    
                    Text(reason)
                        .font(.appCaption1(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                        .lineLimit(2)
                }
                .padding(AppSpacing.sm)
                .background(Color.appPrimary.opacity(0.1))
                .cornerRadius(AppSpacing.radiusSmall)
            }
        }
        .padding(AppSpacing.lg)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .pressAnimation()
    }
    
    private var submissionStoreFallback: some View {
        RoundedRectangle(cornerRadius: 11)
            .fill(Color.gray.opacity(0.08))
            .frame(width: 44, height: 44)
            .overlay(
                Image(systemName: "building.2.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.appSecondary)
            )
    }
}

// MARK: - Withdrawal Card
struct WithdrawalCard: View {
    let withdrawal: WithdrawalRequest
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 11)
                        .fill(withdrawal.status.color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(withdrawal.status.color)
                }
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(withdrawal.paymentMethod ?? "Withdrawal")
                        .font(.appHeadline(.semibold))
                        .foregroundColor(.adaptiveTextPrimary)
                    
                    Text(withdrawal.relativeTime)
                        .font(.appCaption1(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                }
                
                Spacer()
                
                // Status Badge
                HStack(spacing: 4) {
                    Image(systemName: withdrawal.status.iconName)
                        .font(.system(size: 12))
                    Text(withdrawal.status.displayName)
                        .font(.appCaption1(.semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
                .background(withdrawal.status.color)
                .cornerRadius(AppSpacing.radiusSmall)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Amount")
                        .font(.appCaption1(.medium))
                        .foregroundColor(.adaptiveTextSecondary)
                    
                    Text(withdrawal.formattedAmount)
                        .font(.appTitle3(.bold))
                        .foregroundColor(.appPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    Text("Requested")
                        .font(.appCaption1(.medium))
                        .foregroundColor(.adaptiveTextSecondary)
                    
                    Text(withdrawal.formattedDate)
                        .font(.appSubheadline(.medium))
                        .foregroundColor(.adaptiveTextPrimary)
                }
            }
            
            if withdrawal.status == .completed, let processedAt = withdrawal.processedAt {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.appSuccess)
                        .font(.system(size: 14))
                    
                    Text("Processed on \(formattedProcessedDate(processedAt))")
                        .font(.appCaption1(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                }
                .padding(AppSpacing.sm)
                .background(Color.appSuccess.opacity(0.1))
                .cornerRadius(AppSpacing.radiusSmall)
            }
            
            if withdrawal.status == .failed {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.appPrimary)
                        .font(.system(size: 14))
                    
                    Text("Withdrawal failed. Please try again or contact support.")
                        .font(.appCaption1(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                }
                .padding(AppSpacing.sm)
                .background(Color.appPrimary.opacity(0.1))
                .cornerRadius(AppSpacing.radiusSmall)
            }
        }
        .padding(AppSpacing.lg)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    private func formattedProcessedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    ActivityView()
        .environment(AppState.shared)
}
