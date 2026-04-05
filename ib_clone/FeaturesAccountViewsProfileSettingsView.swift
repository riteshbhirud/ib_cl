//
//  ProfileSettingsView.swift
//  ib_clone
//
//  Created by rb on 3/30/26.
//

import SwiftUI

struct ProfileSettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    @State private var fullName: String = ""
    @State private var newEmail: String = ""
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var isSavingName = false
    @State private var isSavingEmail = false
    @State private var isSavingPassword = false
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @State private var showingDeleteConfirmation = false
    
    private let authService = AuthService()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile section
                nameSection
                
                // Email section
                emailSection
                
                // Password section
                passwordSection
                
                // Danger zone
                dangerZone
            }
            .padding(20)
        }
        .background(Color.adaptiveBackground)
        .navigationTitle("Profile Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fullName = appState.currentUser?.name ?? ""
            newEmail = appState.currentUser?.email ?? ""
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Name Section
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "person.fill", title: "Display Name", color: .appSecondary)
            
            VStack(spacing: 12) {
                TextField("Full Name", text: $fullName)
                    .font(.system(size: 16))
                    .padding(14)
                    .background(Color.adaptiveCard)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )
                
                Button(action: saveName) {
                    HStack(spacing: 6) {
                        if isSavingName {
                            ProgressView()
                                .tint(.white)
                        }
                        Text("Update Name")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(nameChanged ? Color.appSecondary : Color.gray.opacity(0.3))
                    .cornerRadius(12)
                }
                .disabled(!nameChanged || isSavingName)
                .pressAnimation()
            }
        }
        .padding(16)
        .background(Color.adaptiveCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Email Section
    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "envelope.fill", title: "Email Address", color: .appCashback)
            
            VStack(spacing: 12) {
                TextField("Email", text: $newEmail)
                    .font(.system(size: 16))
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding(14)
                    .background(Color.adaptiveCard)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )
                
                if !newEmail.trimmingCharacters(in: .whitespaces).isEmpty && !isValidEmail(newEmail.trimmingCharacters(in: .whitespaces)) {
                    Text("Enter a valid email (e.g. name@example.com)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appWarning)
                } else {
                    Text("A verification link will be sent to the new email address.")
                        .font(.system(size: 12))
                        .foregroundColor(.adaptiveTextSecondary)
                }
                
                Button(action: saveEmail) {
                    HStack(spacing: 6) {
                        if isSavingEmail {
                            ProgressView()
                                .tint(.white)
                        }
                        Text("Update Email")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(emailChanged ? Color.appCashback : Color.gray.opacity(0.3))
                    .cornerRadius(12)
                }
                .disabled(!emailChanged || isSavingEmail)
                .pressAnimation()
            }
        }
        .padding(16)
        .background(Color.adaptiveCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Password Section
    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "lock.fill", title: "Change Password", color: .appWarning)
            
            VStack(spacing: 12) {
                SecureField("New Password", text: $newPassword)
                    .font(.system(size: 16))
                    .padding(14)
                    .background(Color.adaptiveCard)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )
                
                SecureField("Confirm New Password", text: $confirmPassword)
                    .font(.system(size: 16))
                    .padding(14)
                    .background(Color.adaptiveCard)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(passwordMismatch ? Color.appPrimary.opacity(0.5) : Color.gray.opacity(0.15), lineWidth: 1)
                    )
                
                if passwordMismatch {
                    Text("Passwords don't match")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appPrimary)
                }
                
                if !newPassword.isEmpty && newPassword.count < 6 {
                    Text("Password must be at least 6 characters")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appWarning)
                }
                
                Button(action: savePassword) {
                    HStack(spacing: 6) {
                        if isSavingPassword {
                            ProgressView()
                                .tint(.white)
                        }
                        Text("Update Password")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(canSavePassword ? Color.appWarning : Color.gray.opacity(0.3))
                    .cornerRadius(12)
                }
                .disabled(!canSavePassword || isSavingPassword)
                .pressAnimation()
            }
        }
        .padding(16)
        .background(Color.adaptiveCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Danger Zone
    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "exclamationmark.triangle.fill", title: "Danger Zone", color: .appPrimary)
            
            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14))
                    Text("Delete Account")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.appPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.appPrimary.opacity(0.1))
                .cornerRadius(12)
            }
            .pressAnimation()
            .confirmationDialog(
                "Delete Account",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete My Account", role: .destructive) {
                    showResult(title: "Not Available", message: "Account deletion requires contacting support at this time.")
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This action is permanent and cannot be undone. All your data will be deleted.")
            }
        }
        .padding(16)
        .background(Color.adaptiveCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appPrimary.opacity(0.15), lineWidth: 1)
        )
    }
    
    // MARK: - Helpers
    
    private func sectionHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 7))
            
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.adaptiveTextPrimary)
        }
    }
    
    private var nameChanged: Bool {
        !fullName.isEmpty && fullName != (appState.currentUser?.name ?? "")
    }
    
    private var emailChanged: Bool {
        !newEmail.trimmingCharacters(in: .whitespaces).isEmpty
        && newEmail.trimmingCharacters(in: .whitespaces) != (appState.currentUser?.email ?? "")
        && isValidEmail(newEmail.trimmingCharacters(in: .whitespaces))
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
    
    private var passwordMismatch: Bool {
        !confirmPassword.isEmpty && newPassword != confirmPassword
    }
    
    private var canSavePassword: Bool {
        newPassword.count >= 6 && newPassword == confirmPassword
    }
    
    private func showResult(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    // MARK: - Actions
    
    private func saveName() {
        Task {
            isSavingName = true
            do {
                try await authService.updateProfile(fullName: fullName)
                // Update local user state
                appState.currentUser?.name = fullName
                showResult(title: "Updated", message: "Your display name has been updated.")
            } catch {
                showResult(title: "Error", message: error.localizedDescription)
            }
            isSavingName = false
        }
    }
    
    private func saveEmail() {
        let trimmedEmail = newEmail.trimmingCharacters(in: .whitespaces)
        
        guard isValidEmail(trimmedEmail) else {
            showResult(title: "Invalid Email", message: "Please enter a valid email address (e.g. name@example.com).")
            return
        }
        
        guard trimmedEmail != (appState.currentUser?.email ?? "") else {
            showResult(title: "No Change", message: "The new email is the same as your current email.")
            return
        }
        
        Task {
            isSavingEmail = true
            do {
                try await authService.updateEmail(newEmail: trimmedEmail)
                showResult(title: "Verification Sent", message: "A confirmation link has been sent to \(trimmedEmail). Please check your inbox to complete the change.")
            } catch {
                let message = friendlyEmailError(error)
                showResult(title: "Email Update Failed", message: message)
            }
            isSavingEmail = false
        }
    }
    
    private func friendlyEmailError(_ error: Error) -> String {
        let desc = error.localizedDescription.lowercased()
        
        if desc.contains("rate limit") || desc.contains("too many") {
            return "Too many attempts. Please wait a few minutes and try again."
        } else if desc.contains("same") || desc.contains("identical") {
            return "The new email must be different from your current email."
        } else if desc.contains("already registered") || desc.contains("already in use") || desc.contains("duplicate") {
            return "This email is already associated with another account."
        } else if desc.contains("invalid") || desc.contains("not valid") {
            return "Please enter a valid email address (e.g. name@example.com)."
        } else if desc.contains("network") || desc.contains("connection") || desc.contains("offline") {
            return "Unable to connect. Please check your internet connection and try again."
        } else if desc.contains("smtp") || desc.contains("send") || desc.contains("deliver") {
            return "We couldn't send the verification email. Please try again later or use a different email provider."
        } else {
            return "Something went wrong: \(error.localizedDescription)"
        }
    }
    
    private func savePassword() {
        Task {
            isSavingPassword = true
            do {
                try await authService.updatePassword(newPassword: newPassword)
                newPassword = ""
                confirmPassword = ""
                showResult(title: "Updated", message: "Your password has been changed successfully.")
            } catch {
                let desc = error.localizedDescription.lowercased()
                let message: String
                if desc.contains("weak") || desc.contains("short") {
                    message = "Password is too weak. Use at least 6 characters with a mix of letters and numbers."
                } else if desc.contains("same") || desc.contains("reuse") {
                    message = "New password must be different from your current password."
                } else if desc.contains("network") || desc.contains("connection") {
                    message = "Unable to connect. Please check your internet connection."
                } else {
                    message = "Something went wrong: \(error.localizedDescription)"
                }
                showResult(title: "Password Update Failed", message: message)
            }
            isSavingPassword = false
        }
    }
}

#Preview {
    NavigationStack {
        ProfileSettingsView()
            .environment(AppState.shared)
    }
}
