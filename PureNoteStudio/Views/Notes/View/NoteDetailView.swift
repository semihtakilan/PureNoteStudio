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
    @State private var attributedText: NSAttributedString
    
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
            
            RichTextEditor(
                attributedText: $attributedText,
                placeholder: ""
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .navigationTitle("")
    }
}
