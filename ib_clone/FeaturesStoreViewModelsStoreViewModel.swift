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
    
    var selectedFilter: OfferFilter = .all
    var isLoading = false
    
    enum OfferFilter: String, CaseIterable {
        case all = "All"
        case expiringSoon = "Expiring Soon"
        case free = "Free After Offer"
        case bonus = "Bonus"
    }
    
    var offers: [Offer] {
        appState.offersByStore[store.id] ?? []
    }
    
    var filteredOffers: [Offer] {
        switch selectedFilter {
        case .all:
            return offers
        case .expiringSoon:
            return offers.filter { $0.expiringSoon }
        case .free:
            return offers.filter { $0.specialTag != nil }
        case .bonus:
            return offers.filter { $0.hasBonus }
        }
    }
    
    var listItemCount: Int {
        appState.getListItems(for: store.id).count
    }
    
    init(store: Store) {
        self.store = store
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
            appState.addToList(offer: offer)
        }
    }
}
