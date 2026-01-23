//
//  AuthService.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import Foundation
import Supabase
import Observation

@MainActor
@Observable
class AuthService {
    var currentUser: Supabase.User?
    var userProfile: UserProfile?
    var isAuthenticated = false
    var isLoading = false
    var errorMessage: String?
    
    private let client = SupabaseManager.shared.client
    
    private nonisolated(unsafe) var authStateTask: Task<Void, Never>?
    
    init() {
        Task { @MainActor in
            await checkSession()
        }
        
        authStateTask = Task { @MainActor in
            await listenToAuthChanges()
        }
    }
    
    deinit {
        authStateTask?.cancel()
    }
    
    // MARK: - Session Management
    
    func checkSession() async {
        do {
            let session = try await client.auth.session
            self.currentUser = session.user
            self.isAuthenticated = true
            await fetchUserProfile()
        } catch {
            self.isAuthenticated = false
            self.currentUser = nil
            print("No active session: \(error)")
        }
    }
    
    func listenToAuthChanges() async {
        do {
            let authChanges = try await client.auth.authStateChanges
            for await (event, session) in authChanges {
                switch event {
                case .signedIn:
                    self.currentUser = session?.user
                    self.isAuthenticated = true
                    await fetchUserProfile()
                case .signedOut:
                    self.currentUser = nil
                    self.userProfile = nil
                    self.isAuthenticated = false
                default:
                    break
                }
            }
        } catch {
            print("Error listening to auth changes: \(error)")
        }
    }
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String, fullName: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            let response = try await client.auth.signUp(
                email: email,
                password: password,
                data: ["full_name": .string(fullName)]
            )
            
            self.currentUser = response.user
            self.isAuthenticated = true
            await fetchUserProfile()
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            let session = try await client.auth.signIn(
                email: email,
                password: password
            )
            
            self.currentUser = session.user
            self.isAuthenticated = true
            await fetchUserProfile()
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func signOut() async throws {
        do {
            try await client.auth.signOut()
            self.currentUser = nil
            self.userProfile = nil
            self.isAuthenticated = false
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Profile Management
    
    func fetchUserProfile() async {
        guard let userId = currentUser?.id else { return }
        
        do {
            let profile: UserProfile = try await client
                .from("user_profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value
            
            self.userProfile = profile
        } catch {
            print("Error fetching profile: \(error)")
        }
    }
    
    func updateProfile(fullName: String) async throws {
        guard let userId = currentUser?.id else { return }
        
        try await client
            .from("user_profiles")
            .update([
                "full_name": fullName,
                "updated_at": ISO8601DateFormatter().string(from: Date())
            ])
            .eq("id", value: userId.uuidString)
            .execute()
        
        await fetchUserProfile()
    }
}
