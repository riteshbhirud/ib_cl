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
    
    var receiptImages: [UIImage] = []
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
        
        guard !receiptImages.isEmpty else {
            submissionError = "Please capture receipt images"
            return
        }
        
        guard let userId = appState.currentUser?.id else {
            submissionError = "User not authenticated"
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
            
            // Upload all receipt images to Supabase Storage
            print("📤 Uploading \(receiptImages.count) receipt image(s)...")
            let submissionService = SubmissionService()
            var receiptUrls: [String] = []
            
            for (index, image) in receiptImages.enumerated() {
                let imageData = image.jpegData(compressionQuality: 0.8) ?? Data()
                let receiptUrl = try await submissionService.uploadReceiptImage(
                    userId: userId,
                    imageData: imageData
                )
                receiptUrls.append(receiptUrl)
                print("✅ Receipt image \(index + 1)/\(receiptImages.count) uploaded")
            }
            
            // Submit the receipt with all image URLs
            try await appState.submitReceipt(
                storeId: store.id,
                items: itemsToSubmit,
                receiptImageUrls: receiptUrls
            )
            
            isSubmitting = false
        } catch {
            isSubmitting = false
            submissionError = error.localizedDescription
            print("❌ Submission error: \(error)")
            throw error
        }
    }
}
