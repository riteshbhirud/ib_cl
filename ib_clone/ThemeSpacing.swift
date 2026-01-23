//
//  Spacing.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct AppSpacing {
    // MARK: - Standard Spacing
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
    
    // MARK: - Corner Radius
    static let radiusSmall: CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge: CGFloat = 16
    static let radiusXLarge: CGFloat = 20
    
    // MARK: - Card
    static let cardPadding: CGFloat = 16
    static let cardCornerRadius: CGFloat = 12
    
    // MARK: - Button
    static let buttonHeight: CGFloat = 50
    static let buttonCornerRadius: CGFloat = 12
    
    // MARK: - Icon Sizes
    static let iconSmall: CGFloat = 16
    static let iconMedium: CGFloat = 24
    static let iconLarge: CGFloat = 32
    static let iconXLarge: CGFloat = 48
}

// MARK: - Spacing Extensions
extension View {
    func cardStyle() -> some View {
        self
            .background(Color.adaptiveCard)
            .cornerRadius(AppSpacing.cardCornerRadius)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .frame(height: AppSpacing.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(Color.appPrimary)
            .cornerRadius(AppSpacing.buttonCornerRadius)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .frame(height: AppSpacing.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(Color.appSecondary)
            .cornerRadius(AppSpacing.buttonCornerRadius)
    }
}
