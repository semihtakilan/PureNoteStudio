//
//  NoteDetailView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 30.06.2026.
//

import SwiftUI

struct NoteDetailView: View {
    @State private var viewModel: NoteDetailViewModel
    @State private var editorWidth: CGFloat = 0

    init(
        note: Note,
        noteRepository: NoteRepository,
        categoryRepository: CategoryRepository
    ) {
        self._viewModel = State(
            initialValue: NoteDetailViewModel(
                note: note,
                noteRepository: noteRepository,
                categoryRepository: categoryRepository
            )
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.title)
                .font(.largeTitle)
                .bold()
            
            if viewModel.isProcessing {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                RichTextEditor(
                    attributedText: $viewModel.attributedText,
                    placeholder: "",
                    resetStyleTrigger: $viewModel.resetStyleTrigger,
                    selectedRange: $viewModel.selectedRange
                )
            }
        }
        .padding()
        .navigationTitle("")
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        editorWidth = geo.size.width - 32
                    }
            }
        )
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Reminder") {
                        
                    }
                    
                    Button("Move to") {
                        
                    }
                    
                    Button("Delete") {
                        
                    }
                    
                } label : {
                    Label("Options", systemImage: "ellipsis")
                }
            }
        }
        .task(id: editorWidth) {
            guard editorWidth > 0 else { return }
            await viewModel.resizeAttachmentsIfNeeded(maxWidth: editorWidth)
        }
        .onDisappear() {
            viewModel.onDisappear()
        }
    }
}

