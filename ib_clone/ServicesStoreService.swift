//
//  StoreService.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import Foundation
import Supabase

@MainActor
class StoreService {
    private let client = SupabaseManager.shared.client
    
    // Fetch all active stores
    func fetchStores() async throws -> [Store] {
        let stores: [Store] = try await client
            .from("stores")
            .select()
            .eq("is_active", value: true)
            .order("sort_order", ascending: true)
            .execute()
            .value
        
        return stores
    }
    
    // Fetch single store by ID
    func fetchStore(id: UUID) async throws -> Store {
        let store: Store = try await client
            .from("stores")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
        
        return store
    }
    
    // Fetch stores with offer counts
    func fetchStoresWithOfferCounts() async throws -> [Store] {
        var stores = try await fetchStores()
        
        for i in stores.indices {
            let count = try await client
                .from("offers")
                .select("id", head: true, count: .exact)
                .eq("store_id", value: stores[i].id.uuidString)
                .eq("is_active", value: true)
                .execute()
                .count ?? 0
            
            stores[i].offerCount = count
        }
        
        return stores
    }
}
