//
//  AddNoteSheet.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 6.07.2026.
//

import SwiftUI

struct AddNoteSheet: View {
    @Environment(AppDependencies.self)
    private var dependencies
    
    @State private var viewModel: AddNoteSheetViewModel?
    
    var body: some View {
        Group {
            if let viewModel {
                AddNoteSheetContentView(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .task {
            if viewModel == nil {
                viewModel = AddNoteSheetViewModel(
                    noteRepository: dependencies.noteRepository,
                    richTextService: dependencies.richTextService
                )
            }
        }
    }
}

struct AddNoteSheetContentView: View {
    @Bindable var viewModel: AddNoteSheetViewModel
    
    @Environment(NotesRouter.self)
    private var router
    
    private var editorWidth: CGFloat {
        (UIScreen.current?.bounds.width ?? 390) - 32
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: - TopToolbar
            HStack {
                Button("Cancel") { router.dissmissSheet() }
                Spacer()
                Button("Save") {
                    if viewModel.saveNote() {
                        router.dissmissSheet()
                    }
                }
                .disabled(viewModel.title.isEmpty)
            }
            .padding(.horizontal)
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
                .padding(.horizontal)
            
            // MARK: - Content
            VStack(spacing: 0) {
                RichTextEditor(
                    attributedText: $viewModel.attributedText,
                    resetStyleTrigger: $viewModel.shouldResetEditorStyle,
                    selectedRange: $viewModel.selectedRange,
                    isFocused: $viewModel.isFocused,
                    formatState: $viewModel.formatState,
                    placeholder: "Start typing your note..."
                )
                .padding(.horizontal)
                
                // MARK: - Accessory Bar
                if viewModel.isFocused {
                    RichTextAccessoryBar(
                        formatState: $viewModel.formatState,
                        onImageLoaded: { image in
                            Task { await viewModel.insertImage(image, editorWidth: editorWidth) }
                        },
                        onCameraTapped: {
                            viewModel.isCameraPresented = true
                        },
                        editorWidth: editorWidth
                    )
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.isCameraPresented) {
            CameraPicker { image in
                Task {
                    await viewModel.insertImage(image, editorWidth: editorWidth)
                }
            }
            .ignoresSafeArea()
        }
        .alert("Not kaydedilemedi", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .background(Color.appPageBackground)
    }
}
