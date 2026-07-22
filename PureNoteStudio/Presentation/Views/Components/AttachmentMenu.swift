//
//  AttachmentMenu.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 22.07.2026.
//

import SwiftUI
import PhotosUI

struct AttachmentMenu: View {
    @State private var selectedItem: PhotosPickerItem?
    
    var onImageLoaded: (UIImage) -> Void
    var onCameraTapped: () -> Void
    
    var body: some View {
        Menu {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("Fotoğraf Galerisi", systemImage: "photo.on.rectangle")
            }
            
            Button {
                onCameraTapped()
            } label: {
                Label("Kamera", systemImage: "camera")
            }
            
        } label: {
            Image(systemName: "paperclip")
                .font(.system(size: 20))
                .foregroundColor(.primary)
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        onImageLoaded(image)
                        selectedItem = nil
                    }
                }
            }
        }
    }
}
