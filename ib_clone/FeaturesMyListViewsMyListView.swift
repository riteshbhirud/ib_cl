//
//  MyListView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct MyListView: View {
    @State private var viewModel = MyListViewModel()
    @Environment(AppState.self) private var appState
    @State private var showingRedeemFlow = false
    @State private var selectedStore: Store?
    @State private var selectedItems: [UserOfferListItem] = []
    var preselectedStoreId: UUID? = nil
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.totalItemsCount == 0 {
                    emptyState
                } else if viewModel.storesWithItems.count == 1 {
                    // Show single store list directly
                    if let store = viewModel.storesWithItems.first {
                        storeListView(for: store)
                    }
                } else if let preselectedStoreId = preselectedStoreId ?? viewModel.selectedStoreId,
                          let store = viewModel.getStore(id: preselectedStoreId) {
                    // Show specific store list
                    storeListView(for: store)
                } else {
                    // Show all stores selector
                    storesSelectorView
                }
            }
            .navigationTitle("My List")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.adaptiveBackground)
        }
        .sheet(isPresented: $showingRedeemFlow) {
            if let store = selectedStore {
                NavigationStack {
                    ReceiptCaptureView(store: store, items: selectedItems)
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        EmptyStateView(
            icon: "tray.fill",
            title: "Your List is Empty",
            message: "Start browsing stores and add offers to see them here!",
            actionTitle: "Browse Stores",
            action: {
                appState.selectedTab = .home
            }
        )
    }
    
    // MARK: - Stores Selector View
    private var storesSelectorView: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Summary Card
                summaryCard
                
                // Stores List
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Select a Store")
                        .font(.appTitle3(.semibold))
                        .foregroundColor(.adaptiveTextPrimary)
                        .padding(.horizontal, AppSpacing.lg)
                    
                    ForEach(viewModel.storesWithItems) { store in
                        NavigationLink(value: store) {
                            StoreListRow(
                                store: store,
                                itemCount: viewModel.getItems(for: store.id).count,
                                totalCashback: viewModel.getTotalCashback(for: store.id)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, AppSpacing.lg)
                    }
                }
            }
            .padding(.vertical, AppSpacing.lg)
        }
        .navigationDestination(for: Store.self) { store in
            storeListView(for: store)
        }
    }
    
    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(spacing: AppSpacing.lg) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Total Items")
                        .font(.appCallout(.medium))
                        .foregroundColor(.adaptiveTextSecondary)
                    
                    Text("\(viewModel.totalItemsCount)")
                        .font(.appTitle1(.bold))
                        .foregroundColor(.adaptiveTextPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    Text("Potential Cashback")
                        .font(.appCallout(.medium))
                        .foregroundColor(.adaptiveTextSecondary)
                    
                    Text(viewModel.totalPotentialCashback.asCurrency)
                        .font(.appTitle1(.bold))
                        .foregroundColor(.appCashback)
                }
            }
        }
        .padding(AppSpacing.xl)
        .background(
            LinearGradient(
                colors: [Color.appSecondary.opacity(0.1), Color.appPrimary.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Store List View
    @ViewBuilder
    private func storeListView(for store: Store) -> some View {
        let items = viewModel.getItems(for: store.id)
        
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    // Store Header
                    Text("\(items.count) items • \(viewModel.getTotalCashback(for: store.id).asCurrency) potential")
                        .font(.appCallout(.medium))
                        .foregroundColor(.adaptiveTextSecondary)
                        .padding(.horizontal, AppSpacing.lg)
                    
                    // Items List
                    ForEach(items) { item in
                        if let offer = item.offer {
                            ListItemRow(
                                item: item,
                                offer: offer,
                                onQuantityChange: { newQuantity in
                                    viewModel.updateQuantity(itemId: item.id, quantity: newQuantity)
                                },
                                onRemove: {
                                    withAnimation {
                                        viewModel.removeItem(itemId: item.id)
                                    }
                                }
                            )
                            .padding(.horizontal, AppSpacing.lg)
                        }
                    }
                }
                .padding(.vertical, AppSpacing.lg)
                .padding(.bottom, 100) // Space for button
            }
            
            // Redeem Button
            VStack(spacing: 0) {
                Divider()
                
                Button {
                    selectedStore = store
                    selectedItems = items
                    showingRedeemFlow = true
                } label: {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Redeem at \(store.name)")
                            .font(.appHeadline(.semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: AppSpacing.buttonHeight)
                    .background(Color.appPrimary)
                    .cornerRadius(AppSpacing.buttonCornerRadius)
                    .padding(AppSpacing.lg)
                }
                .pressAnimation()
            }
            .background(Color.adaptiveCard)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -2)
        }
        .navigationTitle(store.name)
    }
}

// MARK: - Store List Row
struct StoreListRow: View {
    let store: Store
    let itemCount: Int
    let totalCashback: Double
    
    var body: some View {
        HStack(spacing: AppSpacing.lg) {
            // Store Logo
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.appSecondary)
                )
            
            // Info
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(store.name)
                    .font(.appHeadline(.semibold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                Text("\(itemCount) items • \(totalCashback.asCurrency)")
                    .font(.appCallout(.regular))
                    .foregroundColor(.adaptiveTextSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.adaptiveTextSecondary)
        }
        .padding(AppSpacing.lg)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .pressAnimation()
    }
}

// MARK: - List Item Row
struct ListItemRow: View {
    let item: UserOfferListItem
    let offer: Offer
    let onQuantityChange: (Int) -> Void
    let onRemove: () -> Void
    
    @State private var quantity: Int
    
    init(item: UserOfferListItem, offer: Offer, onQuantityChange: @escaping (Int) -> Void, onRemove: @escaping () -> Void) {
        self.item = item
        self.offer = offer
        self.onQuantityChange = onQuantityChange
        self.onRemove = onRemove
        _quantity = State(initialValue: item.quantity)
    }
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Offer Image with AsyncImage
            Group {
                if let imageUrl = offer.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 80, height: 80)
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipped()
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray.opacity(0.3))
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray.opacity(0.3))
                        )
                }
            }
            .cornerRadius(AppSpacing.radiusSmall)
            
            // Offer Info
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(offer.name)
                    .font(.appCallout(.semibold))
                    .foregroundColor(.adaptiveTextPrimary)
                    .lineLimit(2)
                
                HStack(spacing: AppSpacing.xs) {
                    Text(offer.formattedCashback)
                        .font(.appFootnote(.medium))
                        .foregroundColor(.appCashback)
                    
                    Text("×")
                        .font(.appFootnote(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                    
                    Text("\(quantity)")
                        .font(.appFootnote(.semibold))
                        .foregroundColor(.adaptiveTextPrimary)
                    
                    Text("=")
                        .font(.appFootnote(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                    
                    Text((offer.cashback * Double(quantity)).asCurrency)
                        .font(.appFootnote(.bold))
                        .foregroundColor(.appCashback)
                }
            }
            
            Spacer()
            
            // Quantity Selector
            QuantitySelector(
                quantity: $quantity,
                minimum: 1,
                maximum: offer.redemptionLimit,
                size: .small
            )
            .onChange(of: quantity) { oldValue, newValue in
                onQuantityChange(newValue)
            }
        }
        .padding(AppSpacing.md)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onRemove) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    NavigationStack {
        MyListView()
            .environment(AppState.shared)
    }
}
