//
//  UserListService.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import Foundation
import Supabase

@MainActor
class UserListService {
    private let client = SupabaseManager.shared.client
    
    // Fetch all user's saved offers across all stores
    func fetchUserLists(userId: UUID) async throws -> [UserOfferListItem] {
        let items: [UserOfferListItem] = try await client
            .from("user_offer_lists")
            .select("*, offers(*), stores(*)")
            .eq("user_id", value: userId.uuidString)
            .order("added_at", ascending: false)
            .execute()
            .value
        
        return items
    }
    
    // Fetch user's saved offers for a specific store
    func fetchUserListForStore(userId: UUID, storeId: UUID) async throws -> [UserOfferListItem] {
        let items: [UserOfferListItem] = try await client
            .from("user_offer_lists")
            .select("*, offers(*)")
            .eq("user_id", value: userId.uuidString)
            .eq("store_id", value: storeId.uuidString)
            .order("added_at", ascending: false)
            .execute()
            .value
        
        return items
    }
    
    // Add offer to user's list
    func addToList(userId: UUID, offerId: UUID, storeId: UUID, quantity: Int = 1) async throws {
        let item = UserOfferListInsert(
            userId: userId,
            offerId: offerId,
            storeId: storeId,
            quantity: quantity
        )
        
        try await client
            .from("user_offer_lists")
            .upsert(item, onConflict: "user_id,offer_id")
            .execute()
    }
    
    // Update quantity of an item in list
    func updateQuantity(listItemId: UUID, quantity: Int) async throws {
        try await client
            .from("user_offer_lists")
            .update(["quantity": quantity])
            .eq("id", value: listItemId.uuidString)
            .execute()
    }
    
    // Remove offer from user's list
    func removeFromList(listItemId: UUID) async throws {
        try await client
            .from("user_offer_lists")
            .delete()
            .eq("id", value: listItemId.uuidString)
            .execute()
    }
    
    // Remove offer by offer ID
    func removeFromListByOfferId(userId: UUID, offerId: UUID) async throws {
        try await client
            .from("user_offer_lists")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("offer_id", value: offerId.uuidString)
            .execute()
    }
    
    // Check if offer is already in user's list
    func isInList(userId: UUID, offerId: UUID) async throws -> Bool {
        let count = try await client
            .from("user_offer_lists")
            .select("id", head: true, count: .exact)
            .eq("user_id", value: userId.uuidString)
            .eq("offer_id", value: offerId.uuidString)
            .execute()
            .count
        
        return (count ?? 0) > 0
    }
    
    // Get the list item for a specific offer
    func getListItem(userId: UUID, offerId: UUID) async throws -> UserOfferListItem? {
        let items: [UserOfferListItem] = try await client
            .from("user_offer_lists")
            .select("*, offers(*)")
            .eq("user_id", value: userId.uuidString)
            .eq("offer_id", value: offerId.uuidString)
            .execute()
            .value
        
        return items.first
    }
}

// MARK: - Helper Struct

struct UserOfferListInsert: Encodable {
    let userId: UUID
    let offerId: UUID
    let storeId: UUID
    let quantity: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case offerId = "offer_id"
        case storeId = "store_id"
        case quantity
    }
}
