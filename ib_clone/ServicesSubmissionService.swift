//
//  SubmissionService.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import Foundation
import Supabase

@MainActor
class SubmissionService {
    private let client = SupabaseManager.shared.client
    
    // MARK: - Receipt Upload
    
    func uploadReceiptImage(userId: UUID, imageData: Data) async throws -> String {
        let fileName = "\(userId.uuidString)/\(UUID().uuidString).jpg"
        
        try await client.storage
            .from("receipts")
            .upload(
                path: fileName,
                file: imageData,
                options: FileOptions(contentType: "image/jpeg")
            )
        
        // Create signed URL (valid for 1 year)
        let signedURL = try await client.storage
            .from("receipts")
            .createSignedURL(path: fileName, expiresIn: 31536000)
        
        return signedURL.absoluteString
    }
    
    // MARK: - Submission Management
    
    func createSubmission(
        userId: UUID,
        storeId: UUID,
        receiptUrl: String,
        items: [SubmissionItemInput],
        totalCashback: Double
    ) async throws -> Submission {
        // 1. Insert the submission
        let submissionInsert = SubmissionInsert(
            userId: userId,
            storeId: storeId,
            receiptImageUrl: receiptUrl,
            totalCashback: totalCashback
        )
        
        let submission: Submission = try await client
            .from("submissions")
            .insert(submissionInsert)
            .select()
            .single()
            .execute()
            .value
        
        // 2. Insert all submission items
        for item in items {
            let itemInsert = SubmissionItemInsert(
                submissionId: submission.id,
                offerId: item.offerId,
                offerName: item.offerName,
                quantity: item.quantity,
                cashbackPerItem: item.cashbackPerItem,
                totalCashback: item.totalCashback
            )
            
            try await client
                .from("submission_items")
                .insert(itemInsert)
                .execute()
        }
        
        // 3. Remove submitted items from user's list
        for item in items {
            try? await client
                .from("user_offer_lists")
                .delete()
                .eq("user_id", value: userId.uuidString)
                .eq("offer_id", value: item.offerId.uuidString)
                .execute()
        }
        
        return submission
    }
    
    // Fetch all submissions for a user
    func fetchSubmissions(userId: UUID) async throws -> [Submission] {
        let submissions: [Submission] = try await client
            .from("submissions")
            .select("*, stores(*)")
            .eq("user_id", value: userId.uuidString)
            .order("submitted_at", ascending: false)
            .execute()
            .value
        
        return submissions
    }
    
    // Fetch submissions filtered by status
    func fetchSubmissions(userId: UUID, status: Submission.SubmissionStatus) async throws -> [Submission] {
        let submissions: [Submission] = try await client
            .from("submissions")
            .select("*, stores(*)")
            .eq("user_id", value: userId.uuidString)
            .eq("status", value: status.rawValue)
            .order("submitted_at", ascending: false)
            .execute()
            .value
        
        return submissions
    }
    
    // Fetch single submission with all items
    func fetchSubmission(id: UUID) async throws -> Submission {
        var submission: Submission = try await client
            .from("submissions")
            .select("*, stores(*)")
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
        
        // Fetch items separately
        let items: [SubmissionItem] = try await client
            .from("submission_items")
            .select()
            .eq("submission_id", value: id.uuidString)
            .execute()
            .value
        
        submission.items = items
        
        return submission
    }
}

// MARK: - Helper Structs

struct SubmissionItemInput {
    let offerId: UUID
    let offerName: String
    let quantity: Int
    let cashbackPerItem: Double
    let totalCashback: Double
}

struct SubmissionInsert: Encodable {
    let userId: UUID
    let storeId: UUID
    let receiptImageUrl: String
    let totalCashback: Double
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case storeId = "store_id"
        case receiptImageUrl = "receipt_image_url"
        case totalCashback = "total_cashback"
    }
}

struct SubmissionItemInsert: Encodable {
    let submissionId: UUID
    let offerId: UUID
    let offerName: String
    let quantity: Int
    let cashbackPerItem: Double
    let totalCashback: Double
    
    enum CodingKeys: String, CodingKey {
        case submissionId = "submission_id"
        case offerId = "offer_id"
        case offerName = "offer_name"
        case quantity
        case cashbackPerItem = "cashback_per_item"
        case totalCashback = "total_cashback"
    }
}
