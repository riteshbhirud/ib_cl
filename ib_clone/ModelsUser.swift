//
//  User.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var balance: Double
    var totalEarned: Double
    var totalWithdrawn: Double
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        balance: Double = 0.0,
        totalEarned: Double = 0.0,
        totalWithdrawn: Double = 0.0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.balance = balance
        self.totalEarned = totalEarned
        self.totalWithdrawn = totalWithdrawn
        self.createdAt = createdAt
    }
    
    var firstName: String {
        name.components(separatedBy: " ").first ?? name
    }
    
    var canWithdraw: Bool {
        balance >= 15.0
    }
    
    var amountNeededToWithdraw: Double {
        max(0, 15.0 - balance)
    }
}
