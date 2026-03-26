//
//  ReceiptCaptureView.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI
import PhotosUI

struct ReceiptCaptureView: View {
    let store: Store
    let items: [UserOfferListItem]
    
    @State private var viewModel: RedeemViewModel
    @State private var showRequirements = false
    @State private var showImagePicker = false
    @State private var navigateToItemSelection = false
    @Environment(\.dismiss) private var dismiss
    
    init(store: Store, items: [UserOfferListItem]) {
        self.store = store
        self.items = items
        _viewModel = State(initialValue: RedeemViewModel(store: store, items: items))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            instructionsView
        }
        .navigationTitle("Redeem at \(store.name)")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showRequirements) {
            ReceiptRequirementsView(
                store: store,
                onContinue: {
                    showImagePicker = true
                }
            )
        }
        .fullScreenCover(isPresented: $showImagePicker) {
            ReceiptPhotoCapture(
                store: store,
                onPhotosSelected: { images in
                    viewModel.receiptImages = images
                    navigateToItemSelection = true
                }
            )
        }
        .navigationDestination(isPresented: $navigateToItemSelection) {
            SelectItemsView(viewModel: viewModel)
        }
    }
    
    // MARK: - Instructions View
    private var instructionsView: some View {
        VStack(spacing: AppSpacing.xxxl) {
            Spacer()
            
            // Icon and Title
            VStack(spacing: AppSpacing.xl) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary.opacity(0.15), Color.appSecondary.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "doc.text.image")
                        .font(.system(size: 56))
                        .foregroundColor(.appPrimary)
                }
                
                VStack(spacing: AppSpacing.md) {
                    Text("Capture Your Receipt")
                        .font(.appTitle1(.bold))
                        .foregroundColor(.adaptiveTextPrimary)
                    
                    Text("Take clear photos of your complete \(store.name) receipt")
                        .font(.appCallout(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.xxxl)
                }
            }
            
            // Features/Tips
            VStack(spacing: AppSpacing.lg) {
                FeatureRow(
                    icon: "camera.fill",
                    title: "Clear Photos",
                    description: "Make sure all items are visible and readable"
                )
                
                FeatureRow(
                    icon: "photo.stack.fill",
                    title: "Multiple Photos",
                    description: "For long receipts, take multiple photos"
                )
                
                FeatureRow(
                    icon: "lightbulb.fill",
                    title: "Good Lighting",
                    description: "Avoid shadows and ensure receipt is flat"
                )
            }
            .padding(.horizontal, AppSpacing.xl)
            
            Spacer()
            
            // Start Button
            VStack(spacing: AppSpacing.md) {
                PrimaryButton(
                    title: "Capture Receipt",
                    action: {
                        showRequirements = true
                    }
                )
                
                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .font(.appCallout(.semibold))
                        .foregroundColor(.adaptiveTextSecondary)
                }
                .pressAnimation()
            }
            .padding(AppSpacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.adaptiveBackground)
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color.appSecondary.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.appSecondary)
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(.appCallout(.semibold))
                    .foregroundColor(.adaptiveTextPrimary)
                
                Text(description)
                    .font(.appCaption1(.regular))
                    .foregroundColor(.adaptiveTextSecondary)
            }
            
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(Color.adaptiveCard)
        .cornerRadius(AppSpacing.radiusMedium)
    }
}

#Preview {
    NavigationStack {
        ReceiptCaptureView(
            store: MockData.shared.stores[0],
            items: []
        )
    }
}
