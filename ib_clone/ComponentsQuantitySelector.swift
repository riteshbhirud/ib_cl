//
//  QuantitySelector.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct QuantitySelector: View {
    @Binding var quantity: Int
    let minimum: Int
    let maximum: Int
    var size: SelectorSize = .medium
    
    enum SelectorSize {
        case small, medium, large
        
        var height: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 40
            case .large: return 50
            }
        }
        
        var font: Font {
            switch self {
            case .small: return .appFootnote(.semibold)
            case .medium: return .appCallout(.semibold)
            case .large: return .appHeadline(.semibold)
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 16
            case .large: return 18
            }
        }
    }
    
    private var canDecrease: Bool {
        quantity > minimum
    }
    
    private var canIncrease: Bool {
        quantity < maximum
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Decrease Button
            Button(action: {
                if canDecrease {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation(.spring(response: 0.3)) {
                        quantity -= 1
                    }
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: size.iconSize, weight: .semibold))
                    .foregroundColor(canDecrease ? .appPrimary : .gray)
                    .frame(width: size.height, height: size.height)
            }
            .disabled(!canDecrease)
            
            // Quantity Display
            Text("\(quantity)")
                .font(size.font)
                .foregroundColor(.adaptiveTextPrimary)
                .frame(minWidth: size.height)
            
            // Increase Button
            Button(action: {
                if canIncrease {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation(.spring(response: 0.3)) {
                        quantity += 1
                    }
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: size.iconSize, weight: .semibold))
                    .foregroundColor(canIncrease ? .appPrimary : .gray)
                    .frame(width: size.height, height: size.height)
            }
            .disabled(!canIncrease)
        }
        .background(Color.adaptiveCard)
        .cornerRadius(size.height / 2)
        .overlay(
            RoundedRectangle(cornerRadius: size.height / 2)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        QuantitySelector(quantity: .constant(1), minimum: 1, maximum: 5, size: .small)
        QuantitySelector(quantity: .constant(2), minimum: 1, maximum: 5, size: .medium)
        QuantitySelector(quantity: .constant(3), minimum: 1, maximum: 5, size: .large)
    }
    .padding()
    .background(Color.adaptiveBackground)
}
