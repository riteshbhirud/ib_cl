//
//  ActivityViewModel.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

@MainActor
@Observable
class ActivityViewModel {
    private let appState = AppState.shared
    
    enum ActivitySegment: String, CaseIterable {
        case redemptions = "Redemptions"
        case withdrawals = "Withdrawals"
    }
    
    var selectedSegment: ActivitySegment = .redemptions
    var selectedSubmissionFilter: Submission.SubmissionStatus? = nil
    var selectedWithdrawalFilter: WithdrawalRequest.WithdrawalStatus? = nil
    
    // MARK: - Submissions
    
    var submissions: [Submission] {
        appState.getSubmissions(status: selectedSubmissionFilter)
    }
    
    var pendingCount: Int {
        appState.getSubmissions(status: .pending).count
    }
    
    var approvedCount: Int {
        appState.getSubmissions(status: .approved).count
    }
    
    var rejectedCount: Int {
        appState.getSubmissions(status: .rejected).count
    }
    
    // MARK: - Withdrawals
    
    var withdrawals: [WithdrawalRequest] {
        if let filter = selectedWithdrawalFilter {
            return appState.withdrawals.filter { $0.status == filter }
        }
        return appState.withdrawals
    }
    
    var withdrawalPendingCount: Int {
        appState.withdrawals.filter { $0.status == .pending || $0.status == .processing }.count
    }
    
    var withdrawalCompletedCount: Int {
        appState.withdrawals.filter { $0.status == .completed }.count
    }
    
    var withdrawalFailedCount: Int {
        appState.withdrawals.filter { $0.status == .failed }.count
    }
    
    var totalWithdrawalsCount: Int {
        appState.withdrawals.count
    }
}
