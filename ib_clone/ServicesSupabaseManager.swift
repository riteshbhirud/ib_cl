//
//  SupabaseManager.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import Foundation
import Supabase

@MainActor
class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: SupabaseConfig.url,
            supabaseKey: SupabaseConfig.anonKey
        )
    }
    
    var currentUserId: UUID? {
        get async {
            try? await client.auth.session.user.id
        }
    }
    
    var isAuthenticated: Bool {
        get async {
            do {
                _ = try await client.auth.session
                return true
            } catch {
                return false
            }
        }
    }
}
