//
//  LoginView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState
    @Binding var showSignUp: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xxxl) {
                Spacer().frame(height: 40)
                
                // Logo/Header
                VStack(spacing: AppSpacing.lg) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary, Color.appSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        )
                    
                    Text("Welcome Back!")
                        .font(.appTitle1(.bold))
                        .foregroundColor(.adaptiveTextPrimary)
                    
                    Text("Sign in to continue earning cashback")
                        .font(.appCallout(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Form Fields
                VStack(spacing: AppSpacing.lg) {
                    // Email Field
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Email")
                            .font(.appCallout(.medium))
                            .foregroundColor(.adaptiveTextPrimary)
                        
                        TextField("Enter your email", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .padding(AppSpacing.lg)
                            .background(Color.adaptiveCard)
                            .cornerRadius(AppSpacing.radiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Password")
                            .font(.appCallout(.medium))
                            .foregroundColor(.adaptiveTextPrimary)
                        
                        SecureField("Enter your password", text: $password)
                            .padding(AppSpacing.lg)
                            .background(Color.adaptiveCard)
                            .cornerRadius(AppSpacing.radiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                
                // Sign In Button
                PrimaryButton(
                    title: "Sign In",
                    action: signIn,
                    isLoading: isLoading,
                    isDisabled: email.isEmpty || password.isEmpty
                )
                
                // Sign Up Link
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .font(.appCallout(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                    
                    Button("Sign Up") {
                        showSignUp = true
                    }
                    .font(.appCallout(.semibold))
                    .foregroundColor(.appPrimary)
                }
                
                Spacer()
            }
            .padding(AppSpacing.xl)
        }
        .background(Color.adaptiveBackground)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func signIn() {
        Task {
            isLoading = true
            do {
                try await appState.login(email: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isLoading = false
        }
    }
}

#Preview {
    LoginView(showSignUp: .constant(false))
        .environment(AppState.shared)
}
