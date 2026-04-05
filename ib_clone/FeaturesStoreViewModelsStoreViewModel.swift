//
//  StoreViewModel.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

@MainActor
@Observable
class StoreViewModel {
    private let appState = AppState.shared
    let store: Store
    
    var selectedCategory: String? = nil  // nil means "All"
    var selectedSort: OfferSort = .defaultOrder
    var searchText: String = ""
    var isLoadingOffers = false
    
    enum OfferSort: String, CaseIterable {
        case defaultOrder = "Default"
        case cashbackHighToLow = "Highest Cashback"
        case cashbackLowToHigh = "Lowest Cashback"
        case nameAZ = "Name A–Z"
        case expiringSoonFirst = "Expiring Soon"
    }
    
    var offers: [Offer] {
        appState.offersByStore[store.id] ?? []
    }
    
    static let freeAfterOfferFilter = "__free_after_offer__"
    
    /// Pinned category names in display order (these are actual category values in the DB)
    private static let pinnedCategories = ["For You", "What's Hot"]
    
    /// All filter tabs in order: pinned categories, Free After Offer, then remaining alphabetical
    var filterTabs: [(label: String, key: String, count: Int)] {
        var tabs: [(label: String, key: String, count: Int)] = []
        
        let allCategories = Set(offers.flatMap { $0.categories })
        
        // Pinned category tabs (only if offers exist)
        for pinned in Self.pinnedCategories {
            let count = offers.filter { $0.categories.contains(pinned) }.count
            if count > 0 {
                tabs.append((label: pinned, key: pinned, count: count))
            }
        }
        
        // Free After Offer (based on specialTag)
        let freeCount = offers.filter { $0.specialTag != nil }.count
        if freeCount > 0 {
            tabs.append((label: "Free After Offer", key: Self.freeAfterOfferFilter, count: freeCount))
        }
        
        // Remaining categories alphabetically (excluding pinned ones)
        let pinnedSet = Set(Self.pinnedCategories)
        let remaining = allCategories.subtracting(pinnedSet)
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        for cat in remaining {
            let count = offers.filter { $0.categories.contains(cat) }.count
            if count > 0 {
                tabs.append((label: cat, key: cat, count: count))
            }
        }
        
        return tabs
    }
    
    var filteredOffers: [Offer] {
        var result: [Offer]
        
        // When searching, search across ALL offers regardless of category
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = offers.filter { offer in
                offer.name.lowercased().contains(query) ||
                (offer.details?.lowercased().contains(query) ?? false) ||
                (offer.purchaseRequirement?.lowercased().contains(query) ?? false)
            }
        } else if let category = selectedCategory {
            // Apply category filter only when not searching
            if category == Self.freeAfterOfferFilter {
                result = offers.filter { $0.specialTag != nil }
            } else {
                result = offers.filter { $0.categories.contains(category) }
            }
        } else {
            result = offers
        }
        
        // Apply sort
        switch selectedSort {
        case .defaultOrder:
            break
        case .cashbackHighToLow:
            result.sort { $0.cashback > $1.cashback }
        case .cashbackLowToHigh:
            result.sort { $0.cashback < $1.cashback }
        case .nameAZ:
            result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .expiringSoonFirst:
            result.sort { lhs, rhs in
                let lhsExpiring = lhs.expiringSoon == true
                let rhsExpiring = rhs.expiringSoon == true
                if lhsExpiring != rhsExpiring { return lhsExpiring }
                return lhs.cashback > rhs.cashback
            }
        }
        
        return result
    }
    
    var listItemCount: Int {
        appState.getListItems(for: store.id).count
    }
    
    var hasLoadedOffers: Bool {
        appState.offersByStore[store.id] != nil
    }
    
    init(store: Store) {
        self.store = store
    }
    
    func loadOffersIfNeeded() async {
        isLoadingOffers = true
        await appState.loadOffersIfNeeded(storeId: store.id)
        isLoadingOffers = false
    }
    
    func isOfferInList(_ offerId: UUID) -> Bool {
        appState.isOfferInList(offerId)
    }
    
    func toggleOfferInList(_ offer: Offer) {
        if isOfferInList(offer.id) {
            if let item = appState.userListItems.first(where: { $0.offerId == offer.id }) {
                appState.removeFromList(item.id)
            }
        } else {
            appState.addToList(offer: offer, storeId: store.id)
        }
    }
}
