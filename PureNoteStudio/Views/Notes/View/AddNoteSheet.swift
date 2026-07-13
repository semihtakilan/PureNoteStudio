//
//  AddNoteSheet.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 6.07.2026.
//

import SwiftUI
import PhotosUI


struct AddNoteSheet: View {
    let onSave: (String, NSAttributedString) throws -> Void
    
    @Environment(NotesRouter.self)
    private var router
    
    @State private var viewModel = AddNoteSheetViewModel()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var editorWidth: CGFloat = 300
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: - TopToolbar
            HStack {
                Button("Cancel") { router.dissmissSheet() }
                Spacer()
                Button("Save") {
                    try? onSave(viewModel.title, viewModel.attributedText)
                    router.dissmissSheet()
                }
                .disabled(viewModel.title.isEmpty)
            }
            .padding(.top, 16)
            
            Divider().ignoresSafeArea()
            
            // MARK: - Date
            Text(Date.now.formatted(
                .dateTime.day(.defaultDigits).month(.wide).year(.defaultDigits)
                    .hour(.twoDigits(amPM: .abbreviated)).minute(.twoDigits)
                    .locale(Locale(identifier: "en_US"))
            ))
            .font(.subheadline)
            .opacity(0.5)
            .frame(maxWidth: .infinity, alignment: .center)
            
            // MARK: -Title
            TextField("New Title", text: $viewModel.title)
                .font(.largeTitle)
                .bold()
            
            // MARK: - Content
            RichTextEditor(
                attributedText: $viewModel.attributedText,
                placeholder: "Start typing your note...",
                resetStyleTrigger: $viewModel.shouldResetEditorStyle,
                selectedRange: $viewModel.selectedRange
            )
            .onChange(of: viewModel.shouldResetEditorStyle) { _, shouldReset in
                if shouldReset {
                    viewModel.shouldResetEditorStyle = false
                }
            }
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { editorWidth = geo.size.width }
                        .onChange(of: geo.size.width) { _, newWidth in
                            editorWidth = newWidth
                        }
                }
            )

            // MARK: - BottomToolbar
            HStack {
                PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                    Image(systemName: "photo")
                }
            }
        }
        .padding()
        .onChange(of: viewModel.selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await viewModel.insertImage(image, editorWidth: editorWidth)
                }
            }
        }
    }
}
