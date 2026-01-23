//
//  PrimaryButton.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var style: ButtonStyleType = .primary
    
    enum ButtonStyleType {
        case primary
        case secondary
        case outline
        
        var backgroundColor: Color {
            switch self {
            case .primary: return .appPrimary
            case .secondary: return .appSecondary
            case .outline: return .clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .secondary: return .white
            case .outline: return .appPrimary
            }
        }
        
        var borderColor: Color? {
            switch self {
            case .outline: return .appPrimary
            default: return nil
            }
        }
    }
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: AppSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                } else {
                    Text(title)
                        .font(.appHeadline(.semibold))
                        .foregroundColor(style.foregroundColor)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: AppSpacing.buttonHeight)
            .background(isDisabled ? Color.gray.opacity(0.3) : style.backgroundColor)
            .cornerRadius(AppSpacing.buttonCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius)
                    .stroke(style.borderColor ?? Color.clear, lineWidth: 2)
            )
        }
        .disabled(isDisabled || isLoading)
        .pressAnimation()
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Primary Button", action: {})
        PrimaryButton(title: "Secondary Button", action: {}, style: .secondary)
        PrimaryButton(title: "Outline Button", action: {}, style: .outline)
        PrimaryButton(title: "Loading...", action: {}, isLoading: true)
        PrimaryButton(title: "Disabled", action: {}, isDisabled: true)
    }
    .padding()
}
