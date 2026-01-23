//
//  UserOfferListItem.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import Foundation

struct UserOfferListItem: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let offerId: UUID
    let storeId: UUID
    var quantity: Int
    let addedAt: Date
    
    // Joined data (not always populated)
    var offer: Offer?
    var store: Store?
    
    enum CodingKeys: String, CodingKey {
        case id, quantity
        case userId = "user_id"
        case offerId = "offer_id"
        case storeId = "store_id"
        case addedAt = "added_at"
        case offer = "offers"
        case store = "stores"
    }
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        offerId: UUID,
        storeId: UUID,
        quantity: Int = 1,
        addedAt: Date = Date(),
        offer: Offer? = nil,
        store: Store? = nil
    ) {
        self.id = id
        self.userId = userId
        self.offerId = offerId
        self.storeId = storeId
        self.quantity = quantity
        self.addedAt = addedAt
        self.offer = offer
        self.store = store
    }
    
    var totalCashback: Double {
        (offer?.cashback ?? 0) * Double(quantity)
    }
    
    var formattedTotalCashback: String {
        String(format: "$%.2f", totalCashback)
    }
}
