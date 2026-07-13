//
//  NoteDetailView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 30.06.2026.
//

import SwiftUI
import UIKit

struct NoteDetailView: View {
    let note: Note
    
    @State private var viewModel = NoteDetailViewModel()
    @State private var attributedText: NSAttributedString
    @State private var editorWidth: CGFloat = 300
    @State private var isProcessing: Bool = true

    init(note: Note) {
        self.note = note
        if let data = note.contentData,
           let loaded = NSAttributedString.from(data: data) {
            self._attributedText = State(initialValue: loaded)
        } else {
            self._attributedText = State(initialValue: NSAttributedString(string: note.contentText))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(note.title)
                .font(.largeTitle)
                .bold()
            
            if isProcessing {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                RichTextEditor(
                    attributedText: $attributedText,
                    placeholder: ""
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
            isProcessing = true
            attributedText = await viewModel.resizeAttachments(in: attributedText, maxWidth: editorWidth)
            isProcessing = false
        }
    }
}

