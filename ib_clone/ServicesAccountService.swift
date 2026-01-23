//
//  AccountService.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import Foundation
import Supabase
import Auth
import PostgREST
import Storage
import Functions

@MainActor
class AccountService {
    private let client = SupabaseManager.shared.client
    
    // Fetch user profile with balance
    func fetchUserProfile(userId: UUID) async throws -> UserProfile {
        let profile: UserProfile = try await client
            .from("user_profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value
        
        return profile
    }
    
    // Fetch user's transaction history
    func fetchTransactions(userId: UUID) async throws -> [Transaction] {
        let transactions: [Transaction] = try await client
            .from("transactions")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return transactions
    }
    
    // Request a withdrawal
    func requestWithdrawal(userId: UUID, amount: Double) async throws -> WithdrawalRequest {
        // Validate balance
        let profile = try await fetchUserProfile(userId: userId)
        
        guard profile.balance >= amount else {
            throw AccountError.insufficientBalance
        }
        
        guard amount >= 15.0 else {
            throw AccountError.belowMinimum
        }
        
        let withdrawal = WithdrawalInsert(userId: userId, amount: amount)
        
        let result: WithdrawalRequest = try await client
            .from("withdrawal_requests")
            .insert(withdrawal)
            .select()
            .single()
            .execute()
            .value
        
        return result
    }
    
    // Fetch user's withdrawal history
    func fetchWithdrawals(userId: UUID) async throws -> [WithdrawalRequest] {
        let withdrawals: [WithdrawalRequest] = try await client
            .from("withdrawal_requests")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("requested_at", ascending: false)
            .execute()
            .value
        
        return withdrawals
    }
}

// MARK: - Errors

enum AccountError: LocalizedError {
    case insufficientBalance
    case belowMinimum
    
    var errorDescription: String? {
        switch self {
        case .insufficientBalance:
            return "Insufficient balance for withdrawal"
        case .belowMinimum:
            return "Minimum withdrawal amount is $15.00"
        }
    }
}

// MARK: - Helper Structs

struct WithdrawalInsert: Encodable {
    let userId: UUID
    let amount: Double
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case amount
    }
}
