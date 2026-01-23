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
    
    var selectedFilter: Submission.SubmissionStatus? = nil
    
    var submissions: [Submission] {
        appState.getSubmissions(status: selectedFilter)
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
}
