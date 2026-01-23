//
//  MainTabView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        @Bindable var bindableAppState = appState
        
        TabView(selection: $bindableAppState.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppState.Tab.home)
            
            MyListView()
                .tabItem {
                    Label("My List", systemImage: "list.bullet")
                }
                .tag(AppState.Tab.myList)
                .badge(appState.userListItems.count)
            
            ActivityView()
                .tabItem {
                    Label("Activity", systemImage: "clock.fill")
                }
                .tag(AppState.Tab.activity)
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
                .tag(AppState.Tab.account)
        }
        .tint(.appPrimary)
    }
}

#Preview {
    MainTabView()
        .environment(AppState.shared)
}
