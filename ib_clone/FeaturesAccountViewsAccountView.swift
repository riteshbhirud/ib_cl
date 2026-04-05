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
                WithdrawView()
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 0) {
            // Gradient banner
            ZStack(alignment: .bottom) {
                LinearGradient(
                    colors: [Color.appSecondary, Color.appPrimary.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 100)
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                
                // Avatar overlapping the banner
                Circle()
                    .fill(Color.adaptiveCard)
                    .frame(width: 76, height: 76)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .overlay(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appSecondary, Color.appPrimary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 68, height: 68)
                            .overlay(
                                Text(viewModel.user?.name.prefix(1).uppercased() ?? "U")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    )
                    .offset(y: 38)
            }
            
            // Name and email below avatar
            VStack(spacing: 4) {
                Text(viewModel.user?.name ?? "User")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                Text(viewModel.user?.email ?? "")
                    .font(.system(size: 14))
                    .foregroundColor(.adaptiveTextSecondary)
            }
            .padding(.top, 44)
        }
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: 0) {
            StatItem(
                title: "Earned",
                value: viewModel.user?.totalEarned.asCurrency ?? "$0.00",
                icon: "arrow.down.circle.fill",
                color: .appSuccess
            )
            
            // Vertical divider
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(width: 1, height: 44)
            
            StatItem(
                title: "Withdrawn",
                value: viewModel.user?.totalWithdrawn.asCurrency ?? "$0.00",
                icon: "arrow.up.circle.fill",
                color: .appPrimary
            )
        }
        .padding(.vertical, 18)
        .background(Color.adaptiveCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Menu Section
    private var menuSection: some View {
        VStack(spacing: 0) {
            NavigationLink {
                ProfileSettingsView()
            } label: {
                MenuRow(
                    icon: "person.text.rectangle.fill",
                    title: "Profile Settings",
                    showChevron: true
                )
            }
            
            Divider()
                .padding(.leading, 60)
            
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
            
            Link(destination: URL(string: "https://www.getgemback.com/support")!) {
                MenuRow(
                    icon: "questionmark.circle.fill",
                    title: "Help & Support",
                    showChevron: true
                )
            }
            
            Divider()
                .padding(.leading, 60)
            
            Link(destination: URL(string: "https://www.getgemback.com/terms")!) {
                MenuRow(
                    icon: "doc.text.fill",
                    title: "Terms & Privacy",
                    showChevron: true
                )
            }
            
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
    var icon: String? = nil
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color.opacity(0.7))
            }
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
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
        HStack(spacing: 14) {
            // Icon with colored background pill
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.adaptiveTextPrimary)
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.4))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .contentShape(Rectangle())
        .pressAnimation()
    }
}

#Preview {
    AccountView()
        .environment(AppState.shared)
}
