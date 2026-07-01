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
    
    init(repository: NoteRepositoryLive) {
        self._viewModel = State(
            initialValue: NotesViewModel(
                repository: repository
            )
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // MARK: - Title
            Text("Notes")
                .font(.largeTitle)
                .bold(true)
                .padding(.top)
                
            // MARK: - SearchBar
            SearchBarView(searchText: $viewModel.searchText)
            
            // MARK: - Categories
            ScrollView(.horizontal) {
                HStack {
                    ForEach(viewModel.categories) { category in
                        Button(category.name, action: {
                            viewModel.chipSelected(chip: category)
                        })
                    }
                }
            }
            // MARK: - NoteList
            noteListView()
        }
        .padding(.horizontal)
        .task {
            viewModel.load()
        }
    }
}

extension NotesView {
    
    @ViewBuilder
    func noteListView() -> some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.notes) { note in
                    NoteRow(note: note)
                }
            }
        }
    }
}
