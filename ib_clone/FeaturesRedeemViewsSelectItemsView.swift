//
//  SelectItemsView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI

struct SelectItemsView: View {
    @Bindable var viewModel: RedeemViewModel
    @State private var showingSuccess = false
    @State private var showingError = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    // Receipt Thumbnail
                    if let image = viewModel.selectedImage {
                        receiptThumbnail(image)
                    }
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Select Items Purchased")
                            .font(.appTitle3(.semibold))
                            .foregroundColor(.adaptiveTextPrimary)
                        
                        Text("Check the items you purchased and adjust quantities if needed")
                            .font(.appCallout(.regular))
                            .foregroundColor(.adaptiveTextSecondary)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    // Items List
                    VStack(spacing: AppSpacing.md) {
                        ForEach(viewModel.items) { item in
                            if let offer = item.offer {
                                SelectableItemRow(
                                    item: item,
                                    offer: offer,
                                    isSelected: viewModel.selectedItems.contains(item.id),
                                    quantity: viewModel.itemQuantities[item.id] ?? item.quantity,
                                    onToggle: {
                                        withAnimation(.spring(response: 0.3)) {
                                            viewModel.toggleItem(item.id)
                                        }
                                    },
                                    onQuantityChange: { newQuantity in
                                        viewModel.updateQuantity(itemId: item.id, quantity: newQuantity)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
                .padding(.vertical, AppSpacing.lg)
                .padding(.bottom, 120) // Space for bottom bar
            }
            
            // Bottom Submit Bar
            submitBar
        }
        .background(Color.adaptiveBackground)
        .navigationTitle("Select Items")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Submission Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(viewModel.submissionError ?? "An error occurred")
        }
        .navigationDestination(isPresented: $showingSuccess) {
            SubmissionSuccessView(totalCashback: viewModel.totalCashback)
        }
    }
    
    // MARK: - Receipt Thumbnail
    private func receiptThumbnail(_ image: UIImage) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 100)
                .clipped()
                .cornerRadius(AppSpacing.radiusSmall)
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Receipt Image")
                    .font(.appCallout(.semibold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                Text("Tap to view full image")
                    .font(.appCaption1(.regular))
                    .foregroundColor(.adaptiveTextSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.adaptiveTextSecondary)
        }
        .padding(AppSpacing.md)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .padding(.horizontal, AppSpacing.lg)
        .pressAnimation()
    }
    
    // MARK: - Submit Bar
    private var submitBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            VStack(spacing: AppSpacing.md) {
                // Summary
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("\(viewModel.selectedItemsCount) items selected")
                            .font(.appCallout(.medium))
                            .foregroundColor(.adaptiveTextSecondary)
                        
                        Text("Total Cashback")
                            .font(.appCaption1(.medium))
                            .foregroundColor(.adaptiveTextSecondary)
                    }
                    
                    Spacer()
                    
                    Text(viewModel.totalCashback.asCurrency)
                        .font(.appTitle2(.bold))
                        .foregroundColor(.appCashback)
                }
                
                // Submit Button
                PrimaryButton(
                    title: "Submit for Review",
                    action: {
                        Task {
                            do {
                                try await viewModel.submitReceipt()
                                showingSuccess = true
                            } catch {
                                showingError = true
                            }
                        }
                    },
                    isLoading: viewModel.isSubmitting,
                    isDisabled: viewModel.selectedItemsCount == 0
                )
            }
            .padding(AppSpacing.lg)
        }
        .background(Color.adaptiveCard)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -2)
    }
}

// MARK: - Selectable Item Row
struct SelectableItemRow: View {
    let item: UserOfferListItem
    let offer: Offer
    let isSelected: Bool
    @State var quantity: Int
    let onToggle: () -> Void
    let onQuantityChange: (Int) -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: AppSpacing.md) {
                // Checkbox
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .appPrimary : .gray.opacity(0.3))
                
                // Offer Image with AsyncImage
                Group {
                    if let imageUrl = offer.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                    .overlay(ProgressView())
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipped()
                            case .failure:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray.opacity(0.3))
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray.opacity(0.3))
                            )
                    }
                }
                .cornerRadius(AppSpacing.radiusSmall)
                
                // Offer Info
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(offer.name)
                        .font(.appCallout(.medium))
                        .foregroundColor(.adaptiveTextPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(offer.formattedCashback)
                        .font(.appFootnote(.semibold))
                        .foregroundColor(.appCashback)
                }
                
                Spacer()
                
                // Quantity if selected
                if isSelected {
                    QuantitySelector(
                        quantity: $quantity,
                        minimum: 1,
                        maximum: offer.redemptionLimit,
                        size: .small
                    )
                    .onChange(of: quantity) { oldValue, newValue in
                        onQuantityChange(newValue)
                    }
                }
            }
            .padding(AppSpacing.md)
            .background(Color.adaptiveCard)
            .cornerRadius(AppSpacing.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius)
                    .stroke(isSelected ? Color.appPrimary : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        SelectItemsView(
            viewModel: RedeemViewModel(
                store: MockData.shared.stores[0],
                items: []
            )
        )
    }
}
