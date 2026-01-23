//
//  CashbackBadge.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct CashbackBadge: View {
    let amount: Double
    var size: BadgeSize = .medium
    
    enum BadgeSize {
        case small, medium, large
        
        var font: Font {
            switch self {
            case .small: return .system(size: 18, weight: .black, design: .rounded)
            case .medium: return .system(size: 24, weight: .black, design: .rounded)
            case .large: return .system(size: 32, weight: .black, design: .rounded)
            }
        }
    }
    
    var formattedAmount: String {
        String(format: "$%.2f", amount)
    }
    
    var body: some View {
        HStack(spacing: 3) {
            Text(formattedAmount)
                .font(size.font)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.27, blue: 0.23),  // Vibrant red-orange
                            Color(red: 1.0, green: 0.4, blue: 0.0)     // Bright orange
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.orange.opacity(0.4), radius: 3, x: 0, y: 2)
            
            Text("back")
                .font(.system(size: size == .small ? 12 : size == .medium ? 14 : 16, weight: .semibold, design: .rounded))
                .foregroundColor(Color.adaptiveTextSecondary)
                .offset(y: size == .large ? 2 : 1)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        VStack(spacing: 12) {
            Text("Small")
                .font(.caption)
            CashbackBadge(amount: 2.50, size: .small)
        }
        
        VStack(spacing: 12) {
            Text("Medium")
                .font(.caption)
            CashbackBadge(amount: 5.00, size: .medium)
        }
        
        VStack(spacing: 12) {
            Text("Large")
                .font(.caption)
            CashbackBadge(amount: 10.00, size: .large)
        }
    }
    .padding()
    .background(Color.adaptiveBackground)
}
