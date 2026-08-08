//
//  NoteGridCell.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 4.08.2026.
//

import SwiftUI

struct NoteGridCell: View {
    let note: Note
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                // MARK: - Başlık
                Text(note.title)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // MARK: - İçerik Önizlemesi
                if !note.contentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(note.contentText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(6)
                        .multilineTextAlignment(.leading)
                    
                    Text(note.lastEdit.formattedDateString)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.appControlBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
