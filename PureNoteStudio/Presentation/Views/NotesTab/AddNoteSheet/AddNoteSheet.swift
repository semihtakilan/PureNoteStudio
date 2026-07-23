//
//  AddNoteSheet.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 6.07.2026.
//

import SwiftUI

struct AddNoteSheet: View {
    @State var viewModel: AddNoteSheetViewModel
    
    @Environment(NotesRouter.self)
    private var router
    
    private var editorWidth: CGFloat {
        (UIScreen.current?.bounds.width ?? 390) - 32
    }
    
    init(
        noteRepository: NoteRepository,
        richTextService: RichTextServiceProtocol
    ) {
        self._viewModel = State(
            initialValue: AddNoteSheetViewModel(
                noteRepository: noteRepository,
                richTextService: richTextService
            )
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: - TopToolbar
            HStack {
                Button("Cancel") { router.dissmissSheet() }
                Spacer()
                Button("Save") {
                    try? viewModel.saveNote()
                    router.dissmissSheet()
                }
                .disabled(viewModel.title.isEmpty)
            }
            .padding(.top, 16)
            .padding(.horizontal)
            
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
            .padding(.horizontal)
            
            // MARK: -Title
            TextField("New Title", text: $viewModel.title)
                .font(.largeTitle)
                .bold()
                .padding(.horizontal)
            
            // MARK: - Content
            RichTextEditor(
                attributedText: $viewModel.attributedText,
                placeholder: "Start typing your note...",
                resetStyleTrigger: $viewModel.shouldResetEditorStyle,
                selectedRange: $viewModel.selectedRange,
                isFocused: $viewModel.isFocused
            )
            .padding(.horizontal) // Padding eklendi
            .onChange(of: viewModel.shouldResetEditorStyle) { _, shouldReset in
                if shouldReset {
                    viewModel.shouldResetEditorStyle = false
                }
            }
            
            // MARK: - Accessory Bar
            if viewModel.isFocused {
                HStack {
                    AttachmentMenu(
                        onImageLoaded: { image in
                            Task {
                                await viewModel.insertImage(image, editorWidth: editorWidth)
                            }
                        },
                        onCameraTapped: {
                            print("Kamera özelliği yakında eklenecek!")
                        }
                    )
                    
                    Spacer()
                    
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color(UIColor.systemGray6))
            }
        }
    }
}
