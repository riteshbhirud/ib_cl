//
//  Submission.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import Foundation
import SwiftUI

struct Submission: Identifiable, Codable, Hashable {
    
    // Implement Hashable
    static func == (lhs: Submission, rhs: Submission) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    let id: UUID
    let userId: UUID
    let storeId: UUID
    let receiptImageUrl: String  // Primary/first image
    let receiptImageUrls: [String]?  // All receipt images (for long receipts)
    let totalCashback: Double
    let status: SubmissionStatus
    let rejectionReason: String?
    let submittedAt: Date
    let reviewedAt: Date?
    let createdAt: Date?
    let updatedAt: Date?
    var items: [SubmissionItem]?
    var store: Store?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case storeId = "store_id"
        case receiptImageUrl = "receipt_image_url"
        case receiptImageUrls = "receipt_image_urls"
        case totalCashback = "total_cashback"
        case status
        case rejectionReason = "rejection_reason"
        case submittedAt = "submitted_at"
        case reviewedAt = "reviewed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case items
        case store = "stores"
    }
    
    enum SubmissionStatus: String, Codable, CaseIterable {
        case pending
        case approved
        case rejected
        
        var displayName: String {
            switch self {
            case .pending: return "Pending"
            case .approved: return "Approved"
            case .rejected: return "Rejected"
            }
        }
        
        var iconName: String {
            switch self {
            case .pending: return "clock.fill"
            case .approved: return "checkmark.circle.fill"
            case .rejected: return "xmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .pending: return .appWarning
            case .approved: return .appSuccess
            case .rejected: return .appPrimary
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        storeId: UUID,
        receiptImageUrl: String,
        receiptImageUrls: [String]? = nil,
        totalCashback: Double,
        status: SubmissionStatus = .pending,
        rejectionReason: String? = nil,
        submittedAt: Date = Date(),
        reviewedAt: Date? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        items: [SubmissionItem]? = nil,
        store: Store? = nil
    ) {
        self.id = id
        self.userId = userId
        self.storeId = storeId
        self.receiptImageUrl = receiptImageUrl
        self.receiptImageUrls = receiptImageUrls
        self.totalCashback = totalCashback
        self.status = status
        self.rejectionReason = rejectionReason
        self.submittedAt = submittedAt
        self.reviewedAt = reviewedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.items = items
        self.store = store
    }
}

struct SubmissionItem: Identifiable, Codable, Hashable {
    let id: UUID
    let submissionId: UUID
    let offerId: UUID
    let offerName: String
    let quantity: Int
    let cashbackPerItem: Double
    let totalCashback: Double
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case submissionId = "submission_id"
        case offerId = "offer_id"
        case offerName = "offer_name"
        case quantity
        case cashbackPerItem = "cashback_per_item"
        case totalCashback = "total_cashback"
        case createdAt = "created_at"
    }
    
    init(
        id: UUID = UUID(),
        submissionId: UUID,
        offerId: UUID,
        offerName: String,
        quantity: Int,
        cashbackPerItem: Double,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.submissionId = submissionId
        self.offerId = offerId
        self.offerName = offerName
        self.quantity = quantity
        self.cashbackPerItem = cashbackPerItem
        self.totalCashback = cashbackPerItem * Double(quantity)
        self.createdAt = createdAt
    }
}
