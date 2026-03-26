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
    @State private var showingCamera = false
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
                    
                    Image(systemName: "doc.text.image")
                        .font(.system(size: 48))
                        .foregroundColor(.appPrimary)
                }
                
                VStack(spacing: AppSpacing.sm) {
                    Text("No Photos Yet")
                        .font(.appTitle2(.bold))
                        .foregroundColor(.adaptiveTextPrimary)
                    
                    Text("Take or select photos of your complete receipt")
                        .font(.appCallout(.regular))
                        .foregroundColor(.adaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.xl)
                }
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
                    // Info Banner
                    HStack(spacing: AppSpacing.md) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.appPrimary)
                        
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Long receipt?")
                                .font(.appCallout(.semibold))
                                .foregroundColor(.adaptiveTextPrimary)
                            
                            Text("Add more photos to capture the entire receipt")
                                .font(.appCaption1(.regular))
                                .foregroundColor(.adaptiveTextSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding(AppSpacing.md)
                    .background(Color.appPrimary.opacity(0.08))
                    .cornerRadius(AppSpacing.radiusMedium)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.lg)
                    
                    // Images Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
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
                        }
                        
                        // Add More Button
                        addMoreButton
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.lg)
                }
            }
            
            // Bottom Bar
            VStack(spacing: 0) {
                Divider()
                
                VStack(spacing: AppSpacing.sm) {
                    Text("\(capturedImages.count) \(capturedImages.count == 1 ? "photo" : "photos") added")
                        .font(.appCallout(.medium))
                        .foregroundColor(.adaptiveTextSecondary)
                    
                    PrimaryButton(
                        title: "Continue",
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
            imagePickerSourceType = .camera
            showingImagePicker = true
        }) {
            VStack(spacing: AppSpacing.md) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.appPrimary)
                
                Text("Add Photo")
                    .font(.appCallout(.semibold))
                    .foregroundColor(.appPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Color.appPrimary.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                    .strokeBorder(Color.appPrimary, style: StrokeStyle(lineWidth: 2, dash: [8]))
            )
            .cornerRadius(AppSpacing.radiusMedium)
        }
        .pressAnimation()
    }
}

// MARK: - Receipt Image Card
struct ReceiptImageCard: View {
    let image: UIImage
    let index: Int
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Image
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()
                .cornerRadius(AppSpacing.radiusMedium)
            
            // Badge
            HStack(spacing: 4) {
                Image(systemName: "doc.fill")
                    .font(.system(size: 10))
                Text("\(index)")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.appPrimary)
            .cornerRadius(12)
            .padding(8)
            
            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.red))
            }
            .padding(8)
            .offset(x: 8, y: -8)
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
