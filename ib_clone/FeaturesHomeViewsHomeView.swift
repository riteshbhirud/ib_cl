//
//  HomeView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(AppState.self) private var appState
    @State private var showingWithdraw = false
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 0) {
                    // Top section with gradient background
                    VStack(spacing: 20) {
                        headerSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.appSecondary.opacity(0.08),
                                Color.adaptiveBackground
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // Content section
                    VStack(alignment: .leading, spacing: 24) {
                        // Quick Stats Row
                        quickStatsRow
                        
                        // Search Bar
                        searchBar
                        
                        // Stores
                        storesSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                }
            }
            .background(Color.adaptiveBackground)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Store.self) { store in
                StoreDetailView(store: store)
            }
            .refreshable {
                await viewModel.refreshStores()
            }
            .sheet(isPresented: $showingWithdraw) {
                WithdrawView()
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hey, \(appState.currentUser?.firstName ?? "there")")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                Text("Ready to save?")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.adaptiveTextSecondary)
            }
            
            Spacer()
            
            // Profile avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.appSecondary, Color.appPrimary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 42, height: 42)
                .overlay(
                    Text(appState.currentUser?.firstName.prefix(1).uppercased() ?? "?")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                )
        }
    }
    
    // MARK: - Earnings Card
    private var earningsCard: some View {
        Button(action: { showingWithdraw = true }) {
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Your Balance")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(appState.currentUser?.balance.asCurrency ?? "$0.00")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Cash out indicator
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.up.right.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("Cash Out")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                // Progress toward $15 threshold
                if let user = appState.currentUser, !user.canWithdraw {
                    VStack(spacing: 6) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 5)
                                
                                Capsule()
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: geo.size.width * min(user.balance / 15.0, 1.0), height: 5)
                            }
                        }
                        .frame(height: 5)
                        
                        Text("\(user.amountNeededToWithdraw.asCurrency) more to cash out")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, 14)
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "00B894"),
                        Color(hex: "00997A")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .shadow(color: Color(hex: "00B894").opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .pressAnimation()
    }
    
    // MARK: - Quick Stats Row
    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            // My List count
            quickStatPill(
                icon: "list.bullet",
                label: "My List",
                value: "\(appState.userListItems.count)",
                color: .appPrimary
            ) {
                appState.selectedTab = .myList
            }
            
            // Pending submissions
            let pendingCount = appState.submissions.filter { $0.status == .pending }.count
            quickStatPill(
                icon: "clock.fill",
                label: "Pending",
                value: "\(pendingCount)",
                color: .appWarning
            ) {
                appState.selectedTab = .activity
            }
            
            // Total earned
            quickStatPill(
                icon: "star.fill",
                label: "Earned",
                value: appState.currentUser?.totalEarned.asCurrency ?? "$0",
                color: .appSecondary
            ) {
                showingWithdraw = true
            }
        }
    }
    
    private func quickStatPill(icon: String, label: String, value: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack(spacing: 5) {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(color)
                    
                    Text(value)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptiveTextPrimary)
                }
                
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.adaptiveTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.adaptiveCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(color.opacity(0.15), lineWidth: 1)
            )
        }
        .pressAnimation()
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.adaptiveTextSecondary)
            
            TextField("Search stores...", text: $viewModel.searchText)
                .font(.system(size: 15))
                .foregroundColor(.adaptiveTextPrimary)
            
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Color.adaptiveCard)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
        )
    }
    
    // MARK: - Stores Section
    private var storesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Stores")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.adaptiveTextPrimary)
            
            if viewModel.isLoading {
                ForEach(0..<4, id: \.self) { _ in
                    skeletonStoreRow
                }
            } else if viewModel.filteredStores.isEmpty {
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "No Stores Found",
                    message: "Try adjusting your search"
                )
                .frame(height: 200)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.filteredStores) { store in
                        NavigationLink(value: store) {
                            storeRow(store)
                        }
                    }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.searchText)
            }
        }
    }
    
    private func storeRow(_ store: Store) -> some View {
        HStack(spacing: 14) {
            // Store logo
            Group {
                if let logoUrl = store.logoUrl, let url = URL(string: logoUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 52, height: 52)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 52, height: 52)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        case .failure:
                            storeRowFallbackIcon
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    storeRowFallbackIcon
                }
            }
            
            // Store info
            VStack(alignment: .leading, spacing: 3) {
                Text(store.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                if let count = store.offerCount, count > 0 {
                    Text("\(count) offers available")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.adaptiveTextSecondary)
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray.opacity(0.4))
        }
        .padding(14)
        .background(Color.adaptiveCard)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
    
    private var storeRowFallbackIcon: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color.gray.opacity(0.08))
            .frame(width: 52, height: 52)
            .overlay(
                Image(systemName: "building.2.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.appSecondary)
            )
    }
    
    private var skeletonStoreRow: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.gray.opacity(0.12))
                .frame(width: 52, height: 52)
                .shimmer(isLoading: true)
            
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.12))
                    .frame(width: 100, height: 14)
                    .shimmer(isLoading: true)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.12))
                    .frame(width: 70, height: 11)
                    .shimmer(isLoading: true)
            }
            
            Spacer()
        }
        .padding(14)
        .background(Color.adaptiveCard)
        .cornerRadius(16)
    }
}

#Preview {
    HomeView()
        .environment(AppState.shared)
}
