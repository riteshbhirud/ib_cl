//
//  AccountViewModel.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

@MainActor
@Observable
class AccountViewModel {
    private let appState = AppState.shared
    
    var user: User? {
        appState.currentUser
    }
    
    var transactions: [Transaction] {
        appState.transactions
    }
    
    var filteredTransactions: [Transaction] {
        transactions
    }
    
    var isWithdrawing = false
    var withdrawalError: String?
    
    func requestWithdrawal(amount: Double) async throws {
        isWithdrawing = true
        withdrawalError = nil
        
        do {
            try await appState.requestWithdrawal(amount: amount)
            isWithdrawing = false
        } catch {
            isWithdrawing = false
            withdrawalError = error.localizedDescription
            throw error
        }
    }
    
    func logout() {
        appState.logout()
    }
}
