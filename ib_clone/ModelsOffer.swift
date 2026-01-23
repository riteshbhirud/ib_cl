//
//  Offer.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import Foundation

struct Offer: Identifiable, Codable, Hashable {
    let id: UUID
    let storeId: UUID
    let offerId: String?
    let slug: String?
    let name: String
    let imageUrl: String?
    let cashback: Double
    let cashbackText: String?
    let details: String?
    let offerDetail: String?
    let specialTag: String?
    let purchaseRequirement: String?
    let redemptionLimit: Int
    let expiringSoon: Bool
    let hasBonus: Bool
    let isActive: Bool
    let expiresAt: Date?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, slug, cashback, details
        case storeId = "store_id"
        case offerId = "offer_id"
        case imageUrl = "image_url"
        case cashbackText = "cashback_text"
        case offerDetail = "offer_detail"
        case specialTag = "special_tag"
        case purchaseRequirement = "purchase_requirement"
        case redemptionLimit = "redemption_limit"
        case expiringSoon = "expiring_soon"
        case hasBonus = "has_bonus"
        case isActive = "is_active"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
    }
    
    var formattedCashback: String {
        cashbackText ?? String(format: "$%.2f back", cashback)
    }
    
    init(
        id: UUID = UUID(),
        storeId: UUID,
        offerId: String? = nil,
        slug: String? = nil,
        name: String,
        imageUrl: String? = nil,
        cashback: Double,
        cashbackText: String? = nil,
        details: String? = nil,
        offerDetail: String? = nil,
        specialTag: String? = nil,
        purchaseRequirement: String? = nil,
        redemptionLimit: Int = 5,
        expiringSoon: Bool = false,
        hasBonus: Bool = false,
        isActive: Bool = true,
        expiresAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.storeId = storeId
        self.offerId = offerId
        self.slug = slug
        self.name = name
        self.imageUrl = imageUrl
        self.cashback = cashback
        self.cashbackText = cashbackText
        self.details = details
        self.offerDetail = offerDetail
        self.specialTag = specialTag
        self.purchaseRequirement = purchaseRequirement
        self.redemptionLimit = redemptionLimit
        self.expiringSoon = expiringSoon
        self.hasBonus = hasBonus
        self.isActive = isActive
        self.expiresAt = expiresAt
        self.createdAt = createdAt
    }
    
    // For Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Offer, rhs: Offer) -> Bool {
        lhs.id == rhs.id
    }
}
