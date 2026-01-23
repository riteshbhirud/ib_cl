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
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    // Header with greeting and balance
                    headerSection
                    
                    // Search Bar
                    searchBar
                    
                    // Featured Stores
                    if !viewModel.featuredStores.isEmpty {
                        featuredStoresSection
                    }
                    
                    // All Stores
                    allStoresSection
                }
                .padding(AppSpacing.lg)
            }
            .background(Color.adaptiveBackground)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Store.self) { store in
                StoreDetailView(store: store)
            }
            .refreshable {
                await viewModel.refreshStores()
            }
            .onAppear {
                print("🏠 HomeView appeared")
                print("📊 Stores count: \(appState.stores.count)")
                for store in appState.stores {
                    print("  - \(store.name)")
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Hey, \(appState.currentUser?.firstName ?? "there")! 👋")
                    .font(.appTitle2(.bold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                Text("Find awesome cashback deals")
                    .font(.appCallout(.regular))
                    .foregroundColor(.adaptiveTextSecondary)
            }
            
            Spacer()
            
            // Balance Badge
            HStack(spacing: 6) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.appCashback)
                Text(appState.currentUser?.balance.asCurrency ?? "$0.00")
                    .font(.appCallout(.semibold))
                    .foregroundColor(.adaptiveTextPrimary)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(Color.adaptiveCard)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.adaptiveTextSecondary)
            
            TextField("Search stores...", text: $viewModel.searchText)
                .font(.appCallout(.regular))
                .foregroundColor(.adaptiveTextPrimary)
        }
        .padding(AppSpacing.md)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.radiusMedium)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Featured Stores Section
    private var featuredStoresSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Featured Stores")
                .font(.appTitle3(.semibold))
                .foregroundColor(.adaptiveTextPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.lg) {
                    ForEach(viewModel.featuredStores) { store in
                        NavigationLink(value: store) {
                            StoreCard(store: store, isFeatured: true)
                                .frame(width: 180, height: 180)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - All Stores Section
    private var allStoresSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("All Stores")
                .font(.appTitle3(.semibold))
                .foregroundColor(.adaptiveTextPrimary)
            
            if viewModel.isLoading {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(0..<6, id: \.self) { _ in
                        SkeletonStoreCard()
                    }
                }
            } else if viewModel.filteredStores.isEmpty {
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "No Stores Found",
                    message: "Try adjusting your search"
                )
                .frame(height: 300)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.filteredStores) { store in
                        NavigationLink(value: store) {
                            StoreCard(store: store)
                                .frame(height: 150)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(AppState.shared)
}
