//
//  UserProfile.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import Foundation

struct UserProfile: Codable, Identifiable, Equatable {
    let id: UUID
    let email: String?
    var fullName: String?
    var avatarUrl: String?
    var balance: Double
    var totalEarned: Double
    var totalWithdrawn: Double
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, email, balance
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case totalEarned = "total_earned"
        case totalWithdrawn = "total_withdrawn"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Computed property for display name
    var displayName: String {
        fullName?.isEmpty == false ? fullName! : (email ?? "User")
    }
    
    var firstName: String {
        fullName?.components(separatedBy: " ").first ?? displayName
    }
    
    // Formatted balance
    var formattedBalance: String {
        String(format: "$%.2f", balance)
    }
    
    // Check if can withdraw
    var canWithdraw: Bool {
        balance >= 15.0
    }
    
    // Amount needed to withdraw
    var amountNeededToWithdraw: Double {
        max(0, 15.0 - balance)
    }
}
