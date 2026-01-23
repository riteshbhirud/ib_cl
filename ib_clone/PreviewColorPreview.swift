//
//  ColorPreview.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct ColorPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                Text("Color Palette")
                    .font(.appTitle1(.bold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                // Brand Colors
                colorSection(
                    title: "Brand Colors",
                    colors: [
                        ("Primary", Color.appPrimary),
                        ("Secondary", Color.appSecondary)
                    ]
                )
                
                // Semantic Colors
                colorSection(
                    title: "Semantic Colors",
                    colors: [
                        ("Success", Color.appSuccess),
                        ("Warning", Color.appWarning),
                        ("Cashback", Color.appCashback)
                    ]
                )
                
                // Background Colors
                colorSection(
                    title: "Backgrounds",
                    colors: [
                        ("Adaptive Background", Color.adaptiveBackground),
                        ("Adaptive Card", Color.adaptiveCard)
                    ]
                )
                
                // Text Colors
                colorSection(
                    title: "Text Colors",
                    colors: [
                        ("Primary Text", Color.adaptiveTextPrimary),
                        ("Secondary Text", Color.adaptiveTextSecondary)
                    ]
                )
            }
            .padding(AppSpacing.xl)
        }
        .background(Color.adaptiveBackground)
    }
    
    private func colorSection(title: String, colors: [(String, Color)]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(title)
                .font(.appHeadline(.semibold))
                .foregroundColor(.adaptiveTextPrimary)
            
            VStack(spacing: AppSpacing.sm) {
                ForEach(colors, id: \.0) { name, color in
                    HStack {
                        RoundedRectangle(cornerRadius: AppSpacing.radiusSmall)
                            .fill(color)
                            .frame(width: 60, height: 60)
                        
                        Text(name)
                            .font(.appCallout(.medium))
                            .foregroundColor(.adaptiveTextPrimary)
                        
                        Spacer()
                    }
                    .padding(AppSpacing.md)
                    .background(Color.adaptiveCard)
                    .cornerRadius(AppSpacing.radiusMedium)
                }
            }
        }
    }
}

#Preview {
    ColorPreview()
}
