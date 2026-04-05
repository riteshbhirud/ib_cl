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
        print("💰 [Withdrawal] Fetching user profile for \(userId)...")
        let profile = try await fetchUserProfile(userId: userId)
        print("💰 [Withdrawal] Current balance: \(profile.balance), totalWithdrawn: \(profile.totalWithdrawn)")
        
        guard profile.balance >= amount else {
            print("❌ [Withdrawal] Insufficient balance: \(profile.balance) < \(amount)")
            throw AccountError.insufficientBalance
        }
        
        guard amount >= 15.0 else {
            print("❌ [Withdrawal] Below minimum: \(amount) < 15.0")
            throw AccountError.belowMinimum
        }
        
        // Step 1: Insert withdrawal request into DB
        print("💰 [Withdrawal] Step 1: Inserting withdrawal_requests row...")
        let withdrawal = WithdrawalInsert(userId: userId, amount: amount)
        
        let result: WithdrawalRequest = try await client
            .from("withdrawal_requests")
            .insert(withdrawal)
            .select()
            .single()
            .execute()
            .value
        print("✅ [Withdrawal] Step 1 done: withdrawal_requests row ID = \(result.id)")
        
        // Step 2: Deduct balance and update total_withdrawn in user_profiles
        let newBalance = profile.balance - amount
        let newTotalWithdrawn = profile.totalWithdrawn + amount
        print("💰 [Withdrawal] Step 2: Updating user_profiles — balance: \(profile.balance) → \(newBalance), total_withdrawn: \(profile.totalWithdrawn) → \(newTotalWithdrawn)")
        
        let balanceUpdate = BalanceUpdate(balance: newBalance, totalWithdrawn: newTotalWithdrawn)
        try await client
            .from("user_profiles")
            .update(balanceUpdate)
            .eq("id", value: userId.uuidString)
            .execute()
        print("✅ [Withdrawal] Step 2 done: user_profiles updated")
        
        // Step 3: Insert transaction record
        print("💰 [Withdrawal] Step 3: Inserting transactions row...")
        let transactionInsert = TransactionInsert(
            userId: userId,
            type: "withdrawal",
            amount: amount,
            description: "Withdrawal - \(result.paymentMethod ?? "Gift Card")"
        )
        try await client
            .from("transactions")
            .insert(transactionInsert)
            .execute()
        print("✅ [Withdrawal] Step 3 done: transaction row inserted")
        
        print("✅ [Withdrawal] All 3 steps completed successfully!")
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

struct BalanceUpdate: Encodable {
    let balance: Double
    let totalWithdrawn: Double
    
    enum CodingKeys: String, CodingKey {
        case balance
        case totalWithdrawn = "total_withdrawn"
    }
}

struct TransactionInsert: Encodable {
    let userId: UUID
    let type: String
    let amount: Double
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case type, amount, description
    }
}
