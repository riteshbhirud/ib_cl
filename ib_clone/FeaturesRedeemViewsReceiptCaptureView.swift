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
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var navigateToItemSelection = false
    @Environment(\.dismiss) private var dismiss
    
    init(store: Store, items: [UserOfferListItem]) {
        self.store = store
        self.items = items
        _viewModel = State(initialValue: RedeemViewModel(store: store, items: items))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let image = viewModel.selectedImage {
                // Preview captured image
                imagePreview(image)
            } else {
                // Capture instructions
                captureInstructions
            }
        }
        .navigationTitle("Capture Receipt")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $viewModel.selectedImage, sourceType: .photoLibrary)
        }
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(image: $viewModel.selectedImage, sourceType: .camera)
        }
        .navigationDestination(isPresented: $navigateToItemSelection) {
            SelectItemsView(viewModel: viewModel)
        }
    }
    
    // MARK: - Capture Instructions
    private var captureInstructions: some View {
        VStack(spacing: AppSpacing.xxxl) {
            Spacer()
            
            // Instructions
            VStack(spacing: AppSpacing.xl) {
                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: 80))
                    .foregroundColor(.appSecondary)
                
                VStack(spacing: AppSpacing.md) {
                    Text("Capture Your Receipt")
                        .font(.appTitle2(.bold))
                        .foregroundColor(.adaptiveTextPrimary)
                    
                    Text("Make sure your entire receipt is visible and in focus")
                        .font(.appCallout(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.xxxl)
                }
                
                // Tips
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    tipRow(icon: "checkmark.circle.fill", text: "Good lighting")
                    tipRow(icon: "checkmark.circle.fill", text: "All four corners visible")
                    tipRow(icon: "checkmark.circle.fill", text: "Date and items clear")
                }
                .padding(AppSpacing.xl)
                .background(Color.adaptiveCard)
                .cornerRadius(AppSpacing.cardCornerRadius)
                .padding(.horizontal, AppSpacing.xl)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: AppSpacing.md) {
                PrimaryButton(
                    title: "Take Photo",
                    action: {
                        showCamera = true
                    },
                    style: .primary
                )
                
                PrimaryButton(
                    title: "Choose from Library",
                    action: {
                        showImagePicker = true
                    },
                    style: .outline
                )
            }
            .padding(AppSpacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.adaptiveBackground)
    }
    
    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .foregroundColor(.appSuccess)
                .frame(width: 20)
            
            Text(text)
                .font(.appCallout(.regular))
                .foregroundColor(.adaptiveTextPrimary)
        }
    }
    
    // MARK: - Image Preview
    private func imagePreview(_ image: UIImage) -> some View {
        VStack(spacing: 0) {
            // Image
            ScrollView {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(AppSpacing.radiusMedium)
                    .padding(AppSpacing.lg)
            }
            .background(Color.adaptiveBackground)
            
            // Action Buttons
            VStack(spacing: AppSpacing.md) {
                Divider()
                
                HStack(spacing: AppSpacing.md) {
                    PrimaryButton(
                        title: "Retake",
                        action: {
                            viewModel.selectedImage = nil
                        },
                        style: .outline
                    )
                    
                    PrimaryButton(
                        title: "Continue",
                        action: {
                            navigateToItemSelection = true
                        },
                        style: .primary
                    )
                }
                .padding(AppSpacing.lg)
            }
            .background(Color.adaptiveCard)
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
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
