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
    var featuredStores: [Store] = []
    
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
    
    init() {
        loadFeaturedStores()
    }
    
    func loadFeaturedStores() {
        // Take first 3 stores as featured
        featuredStores = Array(stores.prefix(3))
    }
    
    func refreshStores() async {
        isLoading = true
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        isLoading = false
    }
}
