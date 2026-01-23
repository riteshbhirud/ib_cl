//
//  AuthContainerView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct AuthContainerView: View {
    @State private var showSignUp = false
    
    var body: some View {
        NavigationStack {
            Group {
                if showSignUp {
                    SignUpView(showSignUp: $showSignUp)
                } else {
                    LoginView(showSignUp: $showSignUp)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AuthContainerView()
        .environment(AppState.shared)
}
