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
    let slug: String?
    let logoUrl: String?
    let description: String?
    let active: Bool
    let sortOrder: Int
    let createdAt: Date
    var offerCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, slug, description, active
        case logoUrl = "logo_url"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
        case offerCount = "offer_count"
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        slug: String? = nil,
        logoUrl: String? = nil,
        description: String? = nil,
        active: Bool = true,
        sortOrder: Int = 0,
        createdAt: Date = Date(),
        offerCount: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.logoUrl = logoUrl
        self.description = description
        self.active = active
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
