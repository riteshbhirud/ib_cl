//
//  ib_cloneApp.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

@main
struct ib_cloneApp: App {
    @State private var appState = AppState.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isAuthenticated {
                    MainTabView()
                        .environment(appState)
                } else {
                    AuthContainerView()
                        .environment(appState)
                }
            }
            .animation(.easeInOut, value: appState.isAuthenticated)
        }
    }
}
