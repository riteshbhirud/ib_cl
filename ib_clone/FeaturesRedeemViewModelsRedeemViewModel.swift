//
//  RedeemViewModel.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI
import PhotosUI

@MainActor
@Observable
class RedeemViewModel {
    private let appState = AppState.shared
    
    let store: Store
    let items: [UserOfferListItem]
    
    var selectedImage: UIImage?
    var selectedItems: Set<UUID> = []
    var itemQuantities: [UUID: Int] = [:]
    var isSubmitting = false
    var submissionError: String?
    
    var totalCashback: Double {
        selectedItems.reduce(0.0) { total, itemId in
            guard let item = items.first(where: { $0.id == itemId }),
                  let quantity = itemQuantities[itemId],
                  let cashback = item.offer?.cashback else {
                return total
            }
            return total + (cashback * Double(quantity))
        }
    }
    
    var selectedItemsCount: Int {
        selectedItems.count
    }
    
    init(store: Store, items: [UserOfferListItem]) {
        self.store = store
        self.items = items
        
        // Initialize all items as selected with their current quantities
        for item in items {
            selectedItems.insert(item.id)
            itemQuantities[item.id] = item.quantity
        }
    }
    
    func toggleItem(_ itemId: UUID) {
        if selectedItems.contains(itemId) {
            selectedItems.remove(itemId)
        } else {
            selectedItems.insert(itemId)
        }
    }
    
    func updateQuantity(itemId: UUID, quantity: Int) {
        itemQuantities[itemId] = quantity
    }
    
    func submitReceipt() async throws {
        guard !selectedItems.isEmpty else {
            submissionError = "Please select at least one item"
            return
        }
        
        guard selectedImage != nil else {
            submissionError = "Please capture a receipt image"
            return
        }
        
        isSubmitting = true
        submissionError = nil
        
        do {
            let itemsToSubmit = items.filter { selectedItems.contains($0.id) }
                .map { item -> UserOfferListItem in
                    var updatedItem = item
                    if let newQuantity = itemQuantities[item.id] {
                        updatedItem.quantity = newQuantity
                    }
                    return updatedItem
                }
            
            // In a real app, you'd upload the image first and get a URL
            let mockImageUrl = "receipt_\(UUID().uuidString)"
            
            try await appState.submitReceipt(
                storeId: store.id,
                items: itemsToSubmit,
                receiptImageUrl: mockImageUrl
            )
            
            isSubmitting = false
        } catch {
            isSubmitting = false
            submissionError = error.localizedDescription
            throw error
        }
    }
}
