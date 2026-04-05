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
    
    // Fetch all offers for a store (via offer_stores junction table)
    func fetchOffers(storeId: UUID) async throws -> [Offer] {
        // Step 1: Get offer IDs linked to this store from the junction table
        struct OfferIdRow: Codable {
            let offerId: UUID
            enum CodingKeys: String, CodingKey {
                case offerId = "offer_id"
            }
        }
        
        let idRows: [OfferIdRow] = try await client
            .from("offer_stores")
            .select("offer_id")
            .eq("store_id", value: storeId.uuidString)
            .execute()
            .value
        
        print("   📋 Found \(idRows.count) offer IDs in offer_stores for store \(storeId)")
        
        guard !idRows.isEmpty else { return [] }
        
        // Step 2: Fetch the actual offer objects in batches
        // (PostgREST has a URL length limit — 891 UUIDs in a single IN() query exceeds it)
        let allOfferIds = idRows.map { $0.offerId.uuidString }
        let batchSize = 100
        var allOffers: [Offer] = []
        
        for batchStart in stride(from: 0, to: allOfferIds.count, by: batchSize) {
            let batchEnd = min(batchStart + batchSize, allOfferIds.count)
            let batch = Array(allOfferIds[batchStart..<batchEnd])
            
            let offers: [Offer] = try await client
                .from("offers")
                .select()
                .in("id", values: batch)
                .eq("active", value: true)
                .execute()
                .value
            
            allOffers.append(contentsOf: offers)
        }
        
        print("   📦 Fetched \(allOffers.count) offers in \((allOfferIds.count + batchSize - 1) / batchSize) batches")
        return allOffers
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
    func searchOffers(query: String) async throws -> [Offer] {
        let offers: [Offer] = try await client
            .from("offers")
            .select()
            .ilike("name", pattern: "%\(query)%")
            .eq("active", value: true)
            .execute()
            .value
        
        return offers
    }
}
