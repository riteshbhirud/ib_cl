//
//  HomeViewModel.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

@MainActor
@Observable
class HomeViewModel {
    private let appState = AppState.shared
    
    var searchText = ""
    var isLoading = false
    
    var stores: [Store] {
        appState.stores
    }
    
    var filteredStores: [Store] {
        if searchText.isEmpty {
            return stores
        }
        return stores.filter { store in
            store.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func refreshStores() async {
        isLoading = true
        await appState.loadSupabaseData()
        isLoading = false
    }
}
