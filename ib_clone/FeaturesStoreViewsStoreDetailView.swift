//
//  StoreDetailView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct StoreDetailView: View {
    let store: Store
    @State private var viewModel: StoreViewModel
    @Environment(AppState.self) private var appState
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    init(store: Store) {
        self.store = store
        _viewModel = State(initialValue: StoreViewModel(store: store))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    // Store Header
                    storeHeader
                    
                    // Search Bar
                    searchBar
                    
                    // Filter Chips + Sort
                    filterAndSortRow
                    
                    // Offers Grid
                    offersGrid
                }
                .padding(AppSpacing.lg)
                .padding(.bottom, 80) // Space for floating button
            }
            .background(Color.adaptiveBackground)
            
            // Floating "My List" Button
            if viewModel.listItemCount > 0 {
                floatingListButton
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle(store.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadOffersIfNeeded()
        }
    }
    
    // MARK: - Store Header
    private var storeHeader: some View {
        HStack(spacing: 14) {
            // Store logo from DB
            Group {
                if let logoUrl = store.logoUrl, let url = URL(string: logoUrl) {
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
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        case .failure:
                            storeFallbackIcon
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    storeFallbackIcon
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(store.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                if let count = store.offerCount {
                    Text("\(count) offers available")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.adaptiveTextSecondary)
                }
            }
            
            Spacer()
        }
    }
    
    private var storeFallbackIcon: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.1))
            .frame(width: 44, height: 44)
            .overlay(
                Image(systemName: "building.2.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.appSecondary)
            )
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .foregroundColor(.adaptiveTextSecondary)
            
            TextField("Search offers...", text: Bindable(viewModel).searchText)
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
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 10)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.radiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
    
    // MARK: - Filter and Sort Row
    private var filterAndSortRow: some View {
        VStack(spacing: AppSpacing.sm) {
            // Filter Chips: All → pinned → dynamic categories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    // "All" chip (always first)
                    FilterChip(
                        title: "All",
                        count: viewModel.offers.count,
                        isSelected: viewModel.selectedCategory == nil
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.selectedCategory = nil
                        }
                    }
                    
                    // Ordered tabs: pinned first, then remaining categories
                    ForEach(viewModel.filterTabs, id: \.key) { tab in
                        FilterChip(
                            title: tab.label,
                            count: tab.count,
                            isSelected: viewModel.selectedCategory == tab.key
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.selectedCategory = tab.key
                            }
                        }
                    }
                }
            }
            
            // Sort Picker
            HStack {
                Text("\(viewModel.filteredOffers.count) Offers")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                Spacer()
                
                Menu {
                    ForEach(StoreViewModel.OfferSort.allCases, id: \.self) { sort in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.selectedSort = sort
                            }
                        } label: {
                            HStack {
                                Text(sort.rawValue)
                                if viewModel.selectedSort == sort {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 11, weight: .semibold))
                        Text(viewModel.selectedSort.rawValue)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.appPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.appPrimary.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    // MARK: - Offers Grid
    private var offersGrid: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            if !viewModel.hasLoadedOffers {
                // Loading state while offers are being fetched
                VStack(spacing: 16) {
                    ProgressView()
                        .controlSize(.large)
                    Text("Loading offers...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.adaptiveTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
            } else if viewModel.filteredOffers.isEmpty {
                EmptyStateView(
                    icon: viewModel.searchText.isEmpty ? "tag.slash.fill" : "magnifyingglass",
                    title: viewModel.searchText.isEmpty ? "No Offers" : "No Results",
                    message: viewModel.searchText.isEmpty
                        ? "No offers in \(viewModel.selectedCategory ?? "this category")"
                        : "No offers match \"\(viewModel.searchText)\""
                )
                .frame(height: 200)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(viewModel.filteredOffers.enumerated()), id: \.element.id) { index, offer in
                        NavigationLink(value: offer) {
                            OfferCard(
                                offer: offer,
                                isInList: viewModel.isOfferInList(offer.id),
                                onAddToList: {
                                    viewModel.toggleOfferInList(offer)
                                }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.selectedCategory)
            }
        }
        .navigationDestination(for: Offer.self) { offer in
            OfferDetailView(offer: offer, storeId: store.id)
        }
    }
    
    // MARK: - Floating List Button
    private var floatingListButton: some View {
        Button {
            // Switch to My List tab
            appState.selectedTab = .myList
        } label: {
            HStack {
                Image(systemName: "list.bullet")
                    .font(.appHeadline(.semibold))
                Text("My List (\(viewModel.listItemCount))")
                    .font(.appHeadline(.semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, AppSpacing.xl)
            .padding(.vertical, AppSpacing.lg)
            .background(Color.appPrimary)
            .cornerRadius(AppSpacing.buttonCornerRadius)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        }
        .padding(.bottom, AppSpacing.xl)
        .pressAnimation()
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    var count: Int? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 5) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                
                if let count {
                    Text("\(count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(isSelected ? .appPrimary : .white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.9) : Color.gray.opacity(0.4))
                        .clipShape(Capsule())
                }
            }
            .foregroundColor(isSelected ? .white : .adaptiveTextPrimary)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)
            .background(isSelected ? Color.appPrimary : Color.adaptiveCard)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .pressAnimation()
    }
}

#Preview {
    NavigationStack {
        StoreDetailView(store: Store(name: "Walmart", slug: "walmart", offerCount: 12))
            .environment(AppState.shared)
    }
}
