//
//  NoteDetailView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 30.06.2026.
//

import SwiftUI

struct NoteDetailView: View {
    @State private var viewModel: NoteDetailViewModel
    @State private var editorWidth: CGFloat = 300

    init(note: Note) {
        self._viewModel = State(initialValue: NoteDetailViewModel(note: note))
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
        .task(id: editorWidth) {
            guard editorWidth > 0 else { return }
            await viewModel.resizeAttachmentsIfNeeded(maxWidth: editorWidth)
        }
    }
}

