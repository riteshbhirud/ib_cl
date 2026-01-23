//
//  AccountView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct AccountView: View {
    @State private var viewModel = AccountViewModel()
    @State private var showingWithdraw = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    // Profile Header
                    profileHeader
                    
                    // Balance Card
                    BalanceCardView(
                        user: viewModel.user,
                        onWithdrawTapped: {
                            showingWithdraw = true
                        }
                    )
                    .padding(.horizontal, AppSpacing.lg)
                    
                    // Stats
                    statsSection
                    
                    // Menu Items
                    menuSection
                }
                .padding(.vertical, AppSpacing.xl)
            }
            .background(Color.adaptiveBackground)
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingWithdraw) {
                WithdrawView(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        HStack(spacing: AppSpacing.lg) {
            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.appSecondary, Color.appPrimary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Text(viewModel.user?.name.prefix(1).uppercased() ?? "U")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(viewModel.user?.name ?? "User")
                    .font(.appTitle2(.bold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                Text(viewModel.user?.email ?? "")
                    .font(.appCallout(.regular))
                    .foregroundColor(.adaptiveTextSecondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: 0) {
            StatItem(
                title: "Total Earned",
                value: viewModel.user?.totalEarned.asCurrency ?? "$0.00",
                color: .appSuccess
            )
            
            Divider()
                .frame(height: 60)
            
            StatItem(
                title: "Total Withdrawn",
                value: viewModel.user?.totalWithdrawn.asCurrency ?? "$0.00",
                color: .appPrimary
            )
        }
        .padding(.vertical, AppSpacing.lg)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Menu Section
    private var menuSection: some View {
        VStack(spacing: 0) {
            NavigationLink {
                TransactionHistoryView(viewModel: viewModel)
            } label: {
                MenuRow(
                    icon: "clock.arrow.circlepath",
                    title: "Transaction History",
                    showChevron: true
                )
            }
            
            Divider()
                .padding(.leading, 60)
            
            MenuRow(
                icon: "bell.fill",
                title: "Notifications",
                showChevron: true
            )
            
            Divider()
                .padding(.leading, 60)
            
            MenuRow(
                icon: "questionmark.circle.fill",
                title: "Help & Support",
                showChevron: true
            )
            
            Divider()
                .padding(.leading, 60)
            
            MenuRow(
                icon: "doc.text.fill",
                title: "Terms & Privacy",
                showChevron: true
            )
            
            Divider()
                .padding(.leading, 60)
            
            Button(action: {
                viewModel.logout()
            }) {
                MenuRow(
                    icon: "rectangle.portrait.and.arrow.right",
                    title: "Sign Out",
                    color: .appPrimary,
                    showChevron: false
                )
            }
        }
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .padding(.horizontal, AppSpacing.lg)
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Text(value)
                .font(.appTitle3(.bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.appCaption1(.medium))
                .foregroundColor(.adaptiveTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Menu Row
struct MenuRow: View {
    let icon: String
    let title: String
    var color: Color = .appSecondary
    var showChevron: Bool
    
    var body: some View {
        HStack(spacing: AppSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.appCallout(.medium))
                .foregroundColor(.adaptiveTextPrimary)
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.adaptiveTextSecondary)
            }
        }
        .padding(AppSpacing.lg)
        .contentShape(Rectangle())
        .pressAnimation()
    }
}

#Preview {
    AccountView()
        .environment(AppState.shared)
}
