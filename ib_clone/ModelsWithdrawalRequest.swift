//
//  WithdrawalRequest.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import Foundation
import SwiftUI

struct WithdrawalRequest: Codable, Identifiable, Hashable {
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
        
        var iconName: String {
            switch self {
            case .pending: return "clock.fill"
            case .processing: return "arrow.triangle.2.circlepath"
            case .completed: return "checkmark.circle.fill"
            case .failed: return "xmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .pending: return .appWarning
            case .processing: return .appSecondary
            case .completed: return .appSuccess
            case .failed: return .appPrimary
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
    
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: requestedAt, relativeTo: Date())
    }
}
