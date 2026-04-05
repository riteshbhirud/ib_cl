//
//  AuthContainerView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct AuthContainerView: View {
    @State private var showLogin = false
    @State private var showSignUp = false
    @State private var logoAppeared = false
    @State private var contentAppeared = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background — dark navy matching the logo
                Color(hex: "1A1A2E")
                    .ignoresSafeArea()
                
                // Subtle gradient overlay
                LinearGradient(
                    colors: [
                        Color(hex: "4ECDC4").opacity(0.08),
                        Color.clear,
                        Color(hex: "FF6B6B").opacity(0.06)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Logo section
                    VStack(spacing: 24) {
                        // Logo with glow
                        ZStack {
                            // Soft glow behind logo
                            Circle()
                                .fill(Color(hex: "4ECDC4").opacity(0.1))
                                .frame(width: 160, height: 160)
                                .blur(radius: 30)
                            
                            Image("AppLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                        }
                        .scaleEffect(logoAppeared ? 1.0 : 0.8)
                        .opacity(logoAppeared ? 1.0 : 0.0)
                        
                        // App name and tagline
                        VStack(spacing: 8) {
                            Text("GemBack")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("The highest cashback. Period.")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .opacity(logoAppeared ? 1.0 : 0.0)
                    }
                    
                    Spacer()
                    
                    // Feature highlights
                    VStack(spacing: 14) {
                        featureRow(icon: "barcode.viewfinder", text: "Snap your receipt, get cashback")
                        featureRow(icon: "dollarsign.circle.fill", text: "Real cashback on 1000+ products")
                        featureRow(icon: "arrow.up.right.circle.fill", text: "Cash out anytime")
                    }
                    .padding(.horizontal, 40)
                    .opacity(contentAppeared ? 1.0 : 0.0)
                    .offset(y: contentAppeared ? 0 : 20)
                    
                    Spacer().frame(height: 40)
                    
                    // Buttons
                    VStack(spacing: 14) {
                        // Get Started (primary — goes to sign up)
                        Button {
                            showSignUp = true
                        } label: {
                            Text("Get Started")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "4ECDC4"), Color(hex: "3DBDB5")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color(hex: "4ECDC4").opacity(0.35), radius: 12, x: 0, y: 6)
                        }
                        
                        // Sign In (secondary)
                        Button {
                            showLogin = true
                        } label: {
                            Text("I already have an account")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.white.opacity(0.85))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .opacity(contentAppeared ? 1.0 : 0.0)
                    .offset(y: contentAppeared ? 0 : 20)
                    
                    // Terms note
                    Text("By continuing, you agree to our Terms & Privacy Policy")
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.35))
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                        .opacity(contentAppeared ? 1.0 : 0.0)
                }
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showLogin) {
                LoginView(showSignUp: $showSignUp, showLogin: $showLogin)
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView(showSignUp: $showSignUp, showLogin: $showLogin)
            }
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                    logoAppeared = true
                }
                withAnimation(.easeOut(duration: 0.7).delay(0.4)) {
                    contentAppeared = true
                }
            }
        }
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "4ECDC4"))
                .frame(width: 28)
            
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.white.opacity(0.75))
            
            Spacer()
        }
    }
}

#Preview {
    AuthContainerView()
        .environment(AppState.shared)
}
