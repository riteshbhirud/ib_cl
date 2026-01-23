//
//  WithdrawalRequest.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import Foundation

struct WithdrawalRequest: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let amount: Double
    let status: WithdrawalStatus
    let paymentMethod: String?
    let paymentReference: String?
    let requestedAt: Date
    let processedAt: Date?
    
    enum WithdrawalStatus: String, Codable {
        case pending
        case processing
        case completed
        case failed
        
        var displayName: String {
            switch self {
            case .pending: return "Pending"
            case .processing: return "Processing"
            case .completed: return "Completed"
            case .failed: return "Failed"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, amount, status
        case userId = "user_id"
        case paymentMethod = "payment_method"
        case paymentReference = "payment_reference"
        case requestedAt = "requested_at"
        case processedAt = "processed_at"
    }
    
    var formattedAmount: String {
        String(format: "$%.2f", amount)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: requestedAt)
    }
}
