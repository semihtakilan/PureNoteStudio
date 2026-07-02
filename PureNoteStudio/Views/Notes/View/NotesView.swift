//
//  NotesView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 28.06.2026.
//

import SwiftUI
import SwiftData

struct NotesView: View {
    @State private var viewModel: NotesViewModel
    
    init(
        noteRepository: NoteRepository,
        categoryRepository: CategoryRepository
    ) {
        self._viewModel = State(
            initialValue: NotesViewModel(
                noteRepository: noteRepository,
                categoryRepository: categoryRepository
            )
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // MARK: - Title
            Text("Notes")
                .font(.largeTitle)
                .bold(true)
            
            // MARK: - SearchBar
            SearchBarView(searchText: $viewModel.searchText)
            
            // MARK: - Categories
            ChipView(allDatas: $viewModel.chipDatas)
            
            // MARK: - NoteList
            noteListView()
            
            
        }
        .padding(.horizontal)
        .task {
            viewModel.load()
        }
        .background(Color(.systemGray6))
    }
}

extension NotesView {
    
    @ViewBuilder
    func noteListView() -> some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.notes) { note in
                    NoteRow(note: note)
                    if note != viewModel.notes.last {
                        Divider()
                    }
                }
                
                Text("\(viewModel.notes.count) Notes")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .background(.white)
        }
    }
}
