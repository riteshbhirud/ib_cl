//
//  Store.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import Foundation

struct Store: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let logoUrl: String?
    let description: String?
    let isActive: Bool
    let sortOrder: Int
    let createdAt: Date
    var offerCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
        case logoUrl = "logo_url"
        case isActive = "is_active"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
        case offerCount = "offer_count"
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        logoUrl: String? = nil,
        description: String? = nil,
        isActive: Bool = true,
        sortOrder: Int = 0,
        createdAt: Date = Date(),
        offerCount: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.logoUrl = logoUrl
        self.description = description
        self.isActive = isActive
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.offerCount = offerCount
    }
    
    // For Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Store, rhs: Store) -> Bool {
        lhs.id == rhs.id
    }
}
