//
//  TransactionHistoryView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct TransactionHistoryView: View {
    @Bindable var viewModel: AccountViewModel
    
    var body: some View {
        ScrollView {
            if viewModel.transactions.isEmpty {
                EmptyStateView(
                    icon: "clock.arrow.circlepath",
                    title: "No Transactions Yet",
                    message: "Your transaction history will appear here once you start earning and withdrawing cashback"
                )
                .frame(height: 400)
            } else {
                LazyVStack(spacing: AppSpacing.md) {
                    ForEach(viewModel.transactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
                .padding(AppSpacing.lg)
            }
        }
        .background(Color.adaptiveBackground)
        .navigationTitle("Transaction History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Transaction Row
struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: AppSpacing.lg) {
            // Icon
            Circle()
                .fill(transaction.type.isPositive ? Color.appSuccess.opacity(0.1) : Color.appPrimary.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: transaction.type.iconName)
                        .font(.system(size: 20))
                        .foregroundColor(transaction.type.isPositive ? .appSuccess : .appPrimary)
                )
            
            // Info
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(transaction.description ?? transaction.type.displayName)
                    .font(.appCallout(.semibold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                Text(transaction.date.relativeTime)
                    .font(.appCaption1(.regular))
                    .foregroundColor(.adaptiveTextSecondary)
            }
            
            Spacer()
            
            // Amount
            Text(transaction.formattedAmount)
                .font(.appHeadline(.bold))
                .foregroundColor(transaction.type.isPositive ? .appSuccess : .appPrimary)
        }
        .padding(AppSpacing.lg)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        TransactionHistoryView(viewModel: AccountViewModel())
    }
}
