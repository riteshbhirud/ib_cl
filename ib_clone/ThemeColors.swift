//
//  Colors.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

extension Color {
    // MARK: - Brand Colors
    static let appPrimary = Color(hex: "FF6B6B") // Coral Red
    static let appSecondary = Color(hex: "4ECDC4") // Teal
    
    // MARK: - Semantic Colors
    static let appSuccess = Color(hex: "00B894")
    static let appWarning = Color(hex: "FDCB6E")
    static let appCashback = Color(hex: "00B894")
    
    // MARK: - Background Colors
    static let appBackground = Color(hex: "FAFAFA")
    static let appBackgroundDark = Color(hex: "1A1A2E")
    
    // MARK: - Card Colors
    static let appCard = Color.white
    static let appCardDark = Color(hex: "16213E")
    
    // MARK: - Text Colors
    static let appTextPrimary = Color(hex: "2D3436")
    static let appTextSecondary = Color(hex: "636E72")
    
    // MARK: - Adaptive Colors
    static let adaptiveBackground = Color(light: appBackground, dark: appBackgroundDark)
    static let adaptiveCard = Color(light: appCard, dark: appCardDark)
    static let adaptiveTextPrimary = Color(light: appTextPrimary, dark: .white)
    static let adaptiveTextSecondary = Color(light: appTextSecondary, dark: Color(hex: "A0A0A0"))
    
    // MARK: - Gradient
    static let primaryGradient = LinearGradient(
        colors: [appSecondary, appPrimary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Helper Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor(light: UIColor(light), dark: UIColor(dark)))
    }
}

extension UIColor {
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        }
    }
}
