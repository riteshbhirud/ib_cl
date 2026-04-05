//
//  ReceiptPhotoCapture.swift
//  ib_clone
//
//  Created by rb on 3/22/26.
//

import SwiftUI
import PhotosUI

struct ReceiptPhotoCapture: View {
    let store: Store
    let onPhotosSelected: ([UIImage]) -> Void
    
    @State private var capturedImages: [UIImage] = []
    @State private var showingImagePicker = false
    @State private var showingAddMoreOptions = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .camera
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.adaptiveBackground.ignoresSafeArea()
                
                if capturedImages.isEmpty {
                    emptyStateView
                } else {
                    capturedImagesView
                }
            }
            .navigationTitle("Receipt Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !capturedImages.isEmpty {
                        Button("Done") {
                            onPhotosSelected(capturedImages)
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(
                    sourceType: imagePickerSourceType,
                    onImagePicked: { image in
                        capturedImages.append(image)
                    }
                )
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: AppSpacing.xxxl) {
            Spacer()
            
            VStack(spacing: AppSpacing.xl) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.appPrimary.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "camera.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.appPrimary)
                }
                
                VStack(spacing: AppSpacing.sm) {
                    Text("Capture Your Receipt")
                        .font(.appTitle2(.bold))
                        .foregroundColor(.adaptiveTextPrimary)
                    
                    Text("Start by taking a photo of the top of your \(store.name) receipt")
                        .font(.appCallout(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.xl)
                }
                
                // Multi-photo hint
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "photo.stack.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.appSecondary)
                    
                    Text("You can add more photos after for long receipts")
                        .font(.appCaption1(.medium))
                        .foregroundColor(.appSecondary)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.sm)
                .background(Color.appSecondary.opacity(0.1))
                .cornerRadius(20)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: AppSpacing.md) {
                Button(action: {
                    imagePickerSourceType = .camera
                    showingImagePicker = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Take Photo")
                            .font(.appHeadline(.semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: AppSpacing.buttonHeight)
                    .background(Color.appPrimary)
                    .cornerRadius(AppSpacing.buttonCornerRadius)
                }
                .pressAnimation()
                
                Button(action: {
                    imagePickerSourceType = .photoLibrary
                    showingImagePicker = true
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Choose from Library")
                            .font(.appHeadline(.semibold))
                    }
                    .foregroundColor(.appPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: AppSpacing.buttonHeight)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius)
                            .stroke(Color.appPrimary, lineWidth: 2)
                    )
                    .cornerRadius(AppSpacing.buttonCornerRadius)
                }
                .pressAnimation()
            }
            .padding(AppSpacing.lg)
        }
    }
    
    // MARK: - Captured Images View
    private var capturedImagesView: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: AppSpacing.lg) {
                    // Step indicator
                    VStack(spacing: AppSpacing.sm) {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.appSuccess)
                                .font(.system(size: 20))
                            
                            Text("\(capturedImages.count) \(capturedImages.count == 1 ? "photo" : "photos") captured")
                                .font(.appCallout(.semibold))
                                .foregroundColor(.adaptiveTextPrimary)
                            
                            Spacer()
                        }
                        
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "photo.stack.fill")
                                .foregroundColor(.appSecondary)
                                .font(.system(size: 16))
                            
                            Text("Didn't capture everything? Tap \"+\" to add more photos for the rest of your receipt.")
                                .font(.appCaption1(.regular))
                                .foregroundColor(.adaptiveTextSecondary)
                        }
                    }
                    .padding(AppSpacing.md)
                    .background(Color.appSecondary.opacity(0.08))
                    .cornerRadius(AppSpacing.radiusMedium)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.lg)
                    
                    // Images — vertical like a receipt
                    VStack(spacing: 0) {
                        ForEach(Array(capturedImages.enumerated()), id: \.offset) { index, image in
                            ReceiptImageCard(
                                image: image,
                                index: index + 1,
                                onDelete: { [index] in
                                    let idx: Int = index
                                    _ = withAnimation {
                                        capturedImages.remove(at: idx)
                                    }
                                }
                            )
                            
                            // Dashed connector between photos
                            if index < capturedImages.count - 1 {
                                Rectangle()
                                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                    .foregroundColor(.gray.opacity(0.3))
                                    .frame(height: 1)
                                    .padding(.horizontal, AppSpacing.xxxl)
                            }
                        }
                        
                        // Add More Button
                        addMoreButton
                            .padding(.top, AppSpacing.md)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, 100) // Space for bottom bar
                }
            }
            
            // Bottom Bar
            VStack(spacing: 0) {
                Divider()
                
                VStack(spacing: AppSpacing.sm) {
                    Text("All photos captured? Tap continue to review your items.")
                        .font(.appCaption1(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                    
                    PrimaryButton(
                        title: "Continue with \(capturedImages.count) \(capturedImages.count == 1 ? "Photo" : "Photos")",
                        action: {
                            onPhotosSelected(capturedImages)
                            dismiss()
                        }
                    )
                }
                .padding(AppSpacing.lg)
            }
            .background(Color.adaptiveCard)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -2)
        }
    }
    
    // MARK: - Add More Button
    private var addMoreButton: some View {
        Button(action: {
            showingAddMoreOptions = true
        }) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.appPrimary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Add Next Section")
                        .font(.appCallout(.semibold))
                        .foregroundColor(.appPrimary)
                    
                    Text("Capture the next part of your receipt")
                        .font(.appCaption1(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appPrimary.opacity(0.5))
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity)
            .background(Color.appPrimary.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                    .strokeBorder(Color.appPrimary, style: StrokeStyle(lineWidth: 2, dash: [8]))
            )
            .cornerRadius(AppSpacing.radiusMedium)
        }
        .pressAnimation()
        .confirmationDialog("Add More Receipt Photos", isPresented: $showingAddMoreOptions) {
            Button("Take Photo") {
                imagePickerSourceType = .camera
                showingImagePicker = true
            }
            Button("Choose from Library") {
                imagePickerSourceType = .photoLibrary
                showingImagePicker = true
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

// MARK: - Receipt Image Card
struct ReceiptImageCard: View {
    let image: UIImage
    let index: Int
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Image — full width, show entire photo without cropping
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .cornerRadius(AppSpacing.radiusMedium)
            
            // Top bar overlay
            HStack {
                // Badge
                HStack(spacing: 4) {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 10))
                    Text("Photo \(index)")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.appPrimary)
                .cornerRadius(12)
                
                Spacer()
                
                // Delete Button
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2)
                }
            }
            .padding(10)
        }
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
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
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    ReceiptPhotoCapture(
        store: Store(name: "Walmart", logoUrl: nil, description: nil),
        onPhotosSelected: { _ in }
    )
}
