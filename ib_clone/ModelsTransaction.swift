//
//  Transaction.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import Foundation

struct Transaction: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let type: TransactionType
    let amount: Double
    let description: String?
    let date: Date
    let relatedSubmissionId: UUID?
    
    enum TransactionType: String, Codable {
        case credit
        case earning
        case withdrawal
        case bonus
        case adjustment
        
        var displayName: String {
            switch self {
            case .credit, .earning: return "Cashback Earned"
            case .withdrawal: return "Withdrawal"
            case .bonus: return "Bonus"
            case .adjustment: return "Adjustment"
            }
        }
        
        var iconName: String {
            switch self {
            case .credit, .earning: return "plus.circle.fill"
            case .withdrawal: return "arrow.up.circle.fill"
            case .bonus: return "gift.fill"
            case .adjustment: return "pencil.circle.fill"
            }
        }
        
        var isPositive: Bool {
            switch self {
            case .credit, .earning, .bonus, .adjustment:
                return true
            case .withdrawal:
                return false
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, type, amount, description
        case userId = "user_id"
        case date = "created_at"
        case relatedSubmissionId = "submission_id"
    }
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        type: TransactionType,
        amount: Double,
        description: String? = nil,
        date: Date = Date(),
        relatedSubmissionId: UUID? = nil
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.amount = amount
        self.description = description
        self.date = date
        self.relatedSubmissionId = relatedSubmissionId
    }
    
    var formattedAmount: String {
        let sign = type.isPositive ? "+" : "-"
        return "\(sign)$\(String(format: "%.2f", abs(amount)))"
    }
}
