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
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    init(store: Store) {
        self.store = store
        _viewModel = State(initialValue: StoreViewModel(store: store))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    // Store Header
                    storeHeader
                    
                    // Filter Chips
                    filterChips
                    
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
    }
    
    // MARK: - Store Header
    private var storeHeader: some View {
        HStack(spacing: AppSpacing.lg) {
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.appSecondary)
                )
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(store.name)
                    .font(.appTitle2(.bold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                if let description = store.description {
                    Text(description)
                        .font(.appCallout(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                }
                
                if let count = store.offerCount {
                    Text("\(count) offers available")
                        .font(.appFootnote(.medium))
                        .foregroundColor(.appSecondary)
                }
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Filter Chips
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(StoreViewModel.OfferFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.selectedFilter = filter
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Offers Grid
    private var offersGrid: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("\(viewModel.filteredOffers.count) Offers")
                .font(.appTitle3(.semibold))
                .foregroundColor(.adaptiveTextPrimary)
            
            if viewModel.filteredOffers.isEmpty {
                EmptyStateView(
                    icon: "tag.slash.fill",
                    title: "No Offers",
                    message: "No offers match your selected filter"
                )
                .frame(height: 300)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.filteredOffers) { offer in
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
                    }
                }
            }
        }
        .navigationDestination(for: Offer.self) { offer in
            OfferDetailView(offer: offer)
        }
    }
    
    // MARK: - Floating List Button
    private var floatingListButton: some View {
        NavigationLink {
            MyListView(preselectedStoreId: store.id)
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
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            Text(title)
                .font(.appCallout(.medium))
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
        StoreDetailView(store: MockData.shared.stores[0])
            .environment(AppState.shared)
    }
}
