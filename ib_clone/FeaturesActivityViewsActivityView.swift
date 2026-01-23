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
                // Status Filter
                statusFilter
                
                // Submissions List
                if viewModel.submissions.isEmpty {
                    emptyState
                } else {
                    submissionsList
                }
            }
            .background(Color.adaptiveBackground)
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Status Filter
    private var statusFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.md) {
                StatusFilterButton(
                    title: "All",
                    count: viewModel.pendingCount + viewModel.approvedCount + viewModel.rejectedCount,
                    isSelected: viewModel.selectedFilter == nil,
                    action: {
                        withAnimation {
                            viewModel.selectedFilter = nil
                        }
                    }
                )
                
                StatusFilterButton(
                    title: "Pending",
                    count: viewModel.pendingCount,
                    color: .appWarning,
                    isSelected: viewModel.selectedFilter == .pending,
                    action: {
                        withAnimation {
                            viewModel.selectedFilter = .pending
                        }
                    }
                )
                
                StatusFilterButton(
                    title: "Approved",
                    count: viewModel.approvedCount,
                    color: .appSuccess,
                    isSelected: viewModel.selectedFilter == .approved,
                    action: {
                        withAnimation {
                            viewModel.selectedFilter = .approved
                        }
                    }
                )
                
                StatusFilterButton(
                    title: "Rejected",
                    count: viewModel.rejectedCount,
                    color: .appPrimary,
                    isSelected: viewModel.selectedFilter == .rejected,
                    action: {
                        withAnimation {
                            viewModel.selectedFilter = .rejected
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
    
    // MARK: - Empty State
    private var emptyState: some View {
        EmptyStateView(
            icon: "tray.fill",
            title: "No Submissions",
            message: "Your submission history will appear here once you start redeeming offers"
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
                // Store Logo/Icon
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
}

#Preview {
    ActivityView()
        .environment(AppState.shared)
}
