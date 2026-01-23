//
//  MyListViewModel.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

@MainActor
@Observable
class MyListViewModel {
    private let appState = AppState.shared
    
    var selectedStoreId: UUID?
    
    var listItemsByStore: [UUID: [UserOfferListItem]] {
        appState.listItemsByStore
    }
    
    var totalPotentialCashback: Double {
        appState.totalPotentialCashback
    }
    
    var totalItemsCount: Int {
        appState.userListItems.count
    }
    
    var storesWithItems: [Store] {
        let storeIds = Array(listItemsByStore.keys)
        return appState.stores.filter { storeIds.contains($0.id) }
    }
    
    func getItems(for storeId: UUID) -> [UserOfferListItem] {
        appState.getListItems(for: storeId)
    }
    
    func getTotalCashback(for storeId: UUID) -> Double {
        getItems(for: storeId).reduce(0) { $0 + $1.totalCashback }
    }
    
    func updateQuantity(itemId: UUID, quantity: Int) {
        appState.updateQuantity(itemId: itemId, quantity: quantity)
    }
    
    func removeItem(itemId: UUID) {
        appState.removeFromList(itemId)
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func getStore(id: UUID) -> Store? {
        appState.stores.first { $0.id == id }
    }
}
