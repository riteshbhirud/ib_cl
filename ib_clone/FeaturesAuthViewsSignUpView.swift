//
//  SignUpView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct SignUpView: View {
    @Environment(AppState.self) private var appState
    @Binding var showSignUp: Bool
    @Binding var showLogin: Bool
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }
    
    var isFormValid: Bool {
        !fullName.isEmpty && !email.isEmpty && password.count >= 6 && passwordsMatch
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                Spacer().frame(height: 20)
                
                // Logo and header
                VStack(spacing: 16) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    VStack(spacing: 6) {
                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.adaptiveTextPrimary)
                        
                        Text("Start earning cashback today!")
                            .font(.system(size: 15))
                            .foregroundColor(.adaptiveTextSecondary)
                    }
                }
                
                // Form Fields
                VStack(spacing: AppSpacing.lg) {
                    // Full Name
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Full Name")
                            .font(.appCallout(.medium))
                            .foregroundColor(.adaptiveTextPrimary)
                        
                        TextField("Enter your full name", text: $fullName)
                            .padding(AppSpacing.lg)
                            .background(Color.adaptiveCard)
                            .cornerRadius(AppSpacing.radiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // Email
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
                    
                    // Password
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Password")
                            .font(.appCallout(.medium))
                            .foregroundColor(.adaptiveTextPrimary)
                        
                        SecureField("Minimum 6 characters", text: $password)
                            .padding(AppSpacing.lg)
                            .background(Color.adaptiveCard)
                            .cornerRadius(AppSpacing.radiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // Confirm Password
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Confirm Password")
                            .font(.appCallout(.medium))
                            .foregroundColor(.adaptiveTextPrimary)
                        
                        SecureField("Re-enter password", text: $confirmPassword)
                            .padding(AppSpacing.lg)
                            .background(Color.adaptiveCard)
                            .cornerRadius(AppSpacing.radiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                                    .stroke(
                                        !confirmPassword.isEmpty && !passwordsMatch ? Color.appPrimary : Color.gray.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                        
                        if !password.isEmpty && !confirmPassword.isEmpty && !passwordsMatch {
                            Text("Passwords don't match")
                                .font(.appCaption1(.regular))
                                .foregroundColor(.appPrimary)
                        }
                    }
                }
                
                // Sign Up Button
                PrimaryButton(
                    title: "Create Account",
                    action: signUp,
                    isLoading: isLoading,
                    isDisabled: !isFormValid
                )
                
                // Sign In Link
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .font(.system(size: 15))
                        .foregroundColor(.adaptiveTextSecondary)
                    
                    Button("Sign In") {
                        showSignUp = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showLogin = true
                        }
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.appSecondary)
                }
                
                Spacer()
            }
            .padding(AppSpacing.xl)
        }
        .background(Color.adaptiveBackground)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func signUp() {
        Task {
            isLoading = true
            do {
                try await appState.signUp(name: fullName, email: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isLoading = false
        }
    }
}

#Preview {
    SignUpView(showSignUp: .constant(true), showLogin: .constant(false))
        .environment(AppState.shared)
}
