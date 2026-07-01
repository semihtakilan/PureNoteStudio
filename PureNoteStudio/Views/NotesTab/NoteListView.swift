//
//  NoteRow.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 30.06.2026.
//

import SwiftUI
import SwiftData

struct NoteRow: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [Note]
    
    var body: some View {
//        ScrollView {
//            LazyVStack(spacing: 0) {
//                ForEach(notes) { note in
//                    NavigationLink(value: note) {
//                        HStack(alignment: .top) {
//                            VStack(alignment: .leading, spacing: 4) {
//                                HStack {
//                                    Text(note.title)
//                                        .font(.headline)
//                                        .foregroundColor(.primary)
//                                    
//                                    Spacer()
//                                    
//                                    Text(note.lastEdit.relativeTimeDescription)
//                                        .font(.footnote)
//                                        .foregroundColor(.secondary)
//                                }
//                                
//                                Text(note.contentText)
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//                                    .lineLimit(1)
//                            }
//                            
//                            Image(systemName: "chevron.right")
//                                .font(.footnote.weight(.semibold))
//                                .foregroundStyle(.tertiary)
//                                .padding(.leading, 8)
//                        }
//                        .padding(.vertical, 14)
//                        .padding(.leading,16)
//                        .padding(.trailing,12)
//                    }
//                    .buttonStyle(.plain)
//                    .contentShape(Rectangle())
//                    
//                    if note.id != notes.last?.id {
//                        Divider()
//                            .padding(.leading)
//                    }
//                }
//            }
//            .background(.white)
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//            
//        }
    }
}
