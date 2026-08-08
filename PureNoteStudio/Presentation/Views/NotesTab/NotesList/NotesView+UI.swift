//
//  NotesView+UI.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 20.07.2026.
//

import SwiftUI

extension NotesView {

    @ViewBuilder
    func noteListView() -> some View {
        List {
            ForEach(viewModel.notes) { note in
                NoteRow(note: note)
            }
            .onDelete { indexSet in
                viewModel.deleteWhenSwipe(indexSet)
            }
            .listRowBackground(Color.appSurface)

            Text("\(viewModel.notes.count.description) Notes")
                .font(.footnote)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    @ViewBuilder
    func noteGridView() -> some View {
        ScrollView(showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                
                // MARK: - 1. SOL KOLON (Çift İndeksler)
                VStack(spacing: 16) {
                    let leftColumnNotes = Array(viewModel.notes.enumerated()).filter { $0.offset % 2 == 0 }.map { $0.element }
                    
                    ForEach(leftColumnNotes) { note in
                        NoteGridCell(
                            note: note,
                            onTap: { router.push(.detail(note)) },
                            onDelete: { viewModel.delete(note: note) }
                        )
                    }
                }
                
                // MARK: - 2. SAĞ KOLON (Tek İndeksler)
                VStack(spacing: 16) {
                    let rightColumnNotes = Array(viewModel.notes.enumerated()).filter { $0.offset % 2 != 0 }.map { $0.element }
                    
                    ForEach(rightColumnNotes) { note in
                        NoteGridCell(
                            note: note,
                            onTap: { router.push(.detail(note)) },
                            onDelete: { viewModel.delete(note: note) }
                        )
                    }
                }
                
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }
}
