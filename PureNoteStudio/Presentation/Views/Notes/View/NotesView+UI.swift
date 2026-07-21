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
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
