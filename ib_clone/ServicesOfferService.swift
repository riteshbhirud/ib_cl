//
//  OfferService.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import Foundation
import Supabase

@MainActor
class OfferService {
    private let client = SupabaseManager.shared.client
    
    // Fetch all offers for a store
    func fetchOffers(storeId: UUID) async throws -> [Offer] {
        let offers: [Offer] = try await client
            .from("offers")
            .select()
            .eq("store_id", value: storeId.uuidString)
            .eq("is_active", value: true)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return offers
    }
    
    // Fetch single offer by ID
    func fetchOffer(id: UUID) async throws -> Offer {
        let offer: Offer = try await client
            .from("offers")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
        
        return offer
    }
    
    // Search offers by name
    func searchOffers(query: String, storeId: UUID? = nil) async throws -> [Offer] {
        var request = client
            .from("offers")
            .select()
            .ilike("name", pattern: "%\(query)%")
            .eq("is_active", value: true)
        
        if let storeId = storeId {
            request = request.eq("store_id", value: storeId.uuidString)
        }
        
        let offers: [Offer] = try await request.execute().value
        return offers
    }
    
    // Fetch expiring soon offers
    func fetchExpiringSoonOffers(storeId: UUID) async throws -> [Offer] {
        let offers: [Offer] = try await client
            .from("offers")
            .select()
            .eq("store_id", value: storeId.uuidString)
            .eq("is_active", value: true)
            .eq("expiring_soon", value: true)
            .order("expires_at", ascending: true)
            .execute()
            .value
        
        return offers
    }
    
    // Fetch bonus offers
    func fetchBonusOffers(storeId: UUID) async throws -> [Offer] {
        let offers: [Offer] = try await client
            .from("offers")
            .select()
            .eq("store_id", value: storeId.uuidString)
            .eq("is_active", value: true)
            .eq("has_bonus", value: true)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return offers
    }
}
