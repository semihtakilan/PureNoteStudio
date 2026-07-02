//
//  NoteRow.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 1.07.2026.
//

import SwiftUI


struct NoteRow: View {
    @Environment(NotesRouter.self)
    private var route
    
    let note: Note
    
    var body: some View {
        Button {
            route.push(.detail(note))
        } label: {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(note.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("Zaman İbaresi")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(note.contentText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .padding(.leading, 8)
            }
            .padding(.horizontal)
        }
    }
}
