//
//  AddNoteSheet.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 6.07.2026.
//

import SwiftUI

struct AddNoteSheet: View {
    let onSave: (String, String) throws -> Void
    
    @State private var title: String = ""
    @State private var content: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                TextField("New Title", text: $title)
                    .font(.largeTitle)
                
                ZStack {
                    if content.isEmpty {
                        Text("Start typing your note...")
                            .font(.custom("Helvetica", size: 24))
                    }
                    
                    TextEditor(text: $content)
                        .font(.custom("Helvetica", size: 24))
                }
                
            }
            .padding()
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        try? onSave(title, content)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
