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
    @Binding var showLogin: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Logo and header
                VStack(spacing: 16) {
                    Spacer().frame(height: 20)
                    
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    VStack(spacing: 6) {
                        Text("Welcome back")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.adaptiveTextPrimary)
                        
                        Text("Sign in to continue earning cashback")
                            .font(.system(size: 15))
                            .foregroundColor(.adaptiveTextSecondary)
                    }
                    
                    Spacer().frame(height: 8)
                }
                
                // Form area
                VStack(spacing: 20) {
                    // Email field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.adaptiveTextSecondary)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 15))
                                .foregroundColor(focusedField == .email ? .appSecondary : .gray.opacity(0.4))
                            
                            TextField("you@example.com", text: $email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .font(.system(size: 16))
                                .focused($focusedField, equals: .email)
                        }
                        .padding(14)
                        .background(Color.adaptiveCard)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(focusedField == .email ? Color.appSecondary : Color.gray.opacity(0.15), lineWidth: focusedField == .email ? 1.5 : 1)
                        )
                        .animation(.easeInOut(duration: 0.2), value: focusedField)
                    }
                    
                    // Password field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.adaptiveTextSecondary)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 15))
                                .foregroundColor(focusedField == .password ? .appSecondary : .gray.opacity(0.4))
                            
                            SecureField("Enter your password", text: $password)
                                .font(.system(size: 16))
                                .focused($focusedField, equals: .password)
                        }
                        .padding(14)
                        .background(Color.adaptiveCard)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(focusedField == .password ? Color.appSecondary : Color.gray.opacity(0.15), lineWidth: focusedField == .password ? 1.5 : 1)
                        )
                        .animation(.easeInOut(duration: 0.2), value: focusedField)
                    }
                    
                    // Sign In Button
                    PrimaryButton(
                        title: "Sign In",
                        action: signIn,
                        isLoading: isLoading,
                        isDisabled: email.isEmpty || password.isEmpty
                    )
                    .padding(.top, 8)
                    
                    // Sign Up Link
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.system(size: 15))
                            .foregroundColor(.adaptiveTextSecondary)
                        
                        Button("Sign Up") {
                            showLogin = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showSignUp = true
                            }
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.appSecondary)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                Spacer()
            }
        }
        .background(Color.adaptiveBackground)
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture { focusedField = nil }
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
    LoginView(showSignUp: .constant(false), showLogin: .constant(true))
        .environment(AppState.shared)
}
