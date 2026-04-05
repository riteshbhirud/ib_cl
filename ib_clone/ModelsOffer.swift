//
//  Offer.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import Foundation

struct Offer: Identifiable, Codable, Hashable {
    let id: UUID
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
    let category: String?
    let redemptionLimit: Int?
    let expiringSoon: Bool?
    let hasBonus: Bool?
    let active: Bool?
    let expiresAt: Date?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name, slug, cashback, details, active
        case offerId = "offer_id"
        case imageUrl = "image_url"
        case cashbackText = "cashback_text"
        case offerDetail = "offer_detail"
        case specialTag = "special_tag"
        case purchaseRequirement = "purchase_requirement"
        case category
        case redemptionLimit = "redemption_limit"
        case expiringSoon = "expiring_soon"
        case hasBonus = "has_bonus"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
    }
    
    /// Splits comma-separated category string into individual categories
    var categories: [String] {
        guard let category else { return [] }
        return category.split(separator: ",").map { String($0) }
    }
    
    var formattedCashback: String {
        cashbackText ?? String(format: "$%.2f back", cashback)
    }
    
    init(
        id: UUID = UUID(),
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
        category: String? = nil,
        redemptionLimit: Int = 5,
        expiringSoon: Bool = false,
        hasBonus: Bool = false,
        active: Bool = true,
        expiresAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
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
        self.category = category
        self.redemptionLimit = redemptionLimit
        self.expiringSoon = expiringSoon
        self.hasBonus = hasBonus
        self.active = active
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
