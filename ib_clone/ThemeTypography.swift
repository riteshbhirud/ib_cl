//
//  Typography.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct AppTypography {
    // MARK: - Font Sizes
    static let largeTitle: CGFloat = 34
    static let title1: CGFloat = 28
    static let title2: CGFloat = 22
    static let title3: CGFloat = 20
    static let headline: CGFloat = 17
    static let body: CGFloat = 17
    static let callout: CGFloat = 16
    static let subheadline: CGFloat = 15
    static let footnote: CGFloat = 13
    static let caption1: CGFloat = 12
    static let caption2: CGFloat = 11
    
    // MARK: - Font Weights
    enum Weight {
        case regular
        case medium
        case semibold
        case bold
        
        var fontWeight: Font.Weight {
            switch self {
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            }
        }
    }
}

extension Font {
    // MARK: - Custom Typography
    static func appLargeTitle(_ weight: AppTypography.Weight = .bold) -> Font {
        .system(size: AppTypography.largeTitle, weight: weight.fontWeight)
    }
    
    static func appTitle1(_ weight: AppTypography.Weight = .bold) -> Font {
        .system(size: AppTypography.title1, weight: weight.fontWeight)
    }
    
    static func appTitle2(_ weight: AppTypography.Weight = .bold) -> Font {
        .system(size: AppTypography.title2, weight: weight.fontWeight)
    }
    
    static func appTitle3(_ weight: AppTypography.Weight = .semibold) -> Font {
        .system(size: AppTypography.title3, weight: weight.fontWeight)
    }
    
    static func appHeadline(_ weight: AppTypography.Weight = .semibold) -> Font {
        .system(size: AppTypography.headline, weight: weight.fontWeight)
    }
    
    static func appBody(_ weight: AppTypography.Weight = .regular) -> Font {
        .system(size: AppTypography.body, weight: weight.fontWeight)
    }
    
    static func appCallout(_ weight: AppTypography.Weight = .regular) -> Font {
        .system(size: AppTypography.callout, weight: weight.fontWeight)
    }
    
    static func appSubheadline(_ weight: AppTypography.Weight = .regular) -> Font {
        .system(size: AppTypography.subheadline, weight: weight.fontWeight)
    }
    
    static func appFootnote(_ weight: AppTypography.Weight = .regular) -> Font {
        .system(size: AppTypography.footnote, weight: weight.fontWeight)
    }
    
    static func appCaption1(_ weight: AppTypography.Weight = .regular) -> Font {
        .system(size: AppTypography.caption1, weight: weight.fontWeight)
    }
    
    static func appCaption2(_ weight: AppTypography.Weight = .regular) -> Font {
        .system(size: AppTypography.caption2, weight: weight.fontWeight)
    }
}

// MARK: - Text Style Modifiers
extension View {
    func appLargeTitleStyle(_ weight: AppTypography.Weight = .bold) -> some View {
        self.font(.appLargeTitle(weight))
    }
    
    func appTitle1Style(_ weight: AppTypography.Weight = .bold) -> some View {
        self.font(.appTitle1(weight))
    }
    
    func appTitle2Style(_ weight: AppTypography.Weight = .bold) -> some View {
        self.font(.appTitle2(weight))
    }
    
    func appTitle3Style(_ weight: AppTypography.Weight = .semibold) -> some View {
        self.font(.appTitle3(weight))
    }
    
    func appHeadlineStyle(_ weight: AppTypography.Weight = .semibold) -> some View {
        self.font(.appHeadline(weight))
    }
    
    func appBodyStyle(_ weight: AppTypography.Weight = .regular) -> some View {
        self.font(.appBody(weight))
    }
    
    func appCalloutStyle(_ weight: AppTypography.Weight = .regular) -> some View {
        self.font(.appCallout(weight))
    }
    
    func appSubheadlineStyle(_ weight: AppTypography.Weight = .regular) -> some View {
        self.font(.appSubheadline(weight))
    }
    
    func appFootnoteStyle(_ weight: AppTypography.Weight = .regular) -> some View {
        self.font(.appFootnote(weight))
    }
    
    func appCaptionStyle(_ weight: AppTypography.Weight = .regular) -> some View {
        self.font(.appCaption1(weight))
    }
}
