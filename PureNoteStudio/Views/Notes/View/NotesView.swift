//
//  NotesView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 28.06.2026.
//

import SwiftUI
import SwiftData

struct NotesView: View {
    @State var viewModel: NotesViewModel
    @Environment(NotesRouter.self)
    private var router
    
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
        VStack(alignment: .center, spacing: 15) {
            // MARK: - SearchBar
            SearchBarView(searchText: $viewModel.searchText)
            
            // MARK: - Categories
            ChipView(chipDatas: viewModel.chipDatas, selectedChip: $viewModel.selectedChip)
                .onChange(of: viewModel.selectedChip?.name ?? "All") { oldValue, newValue in
                    viewModel.handleChipChange(newValue)
                }
            // MARK: - NoteList
            noteListView()
            
            Text("\(viewModel.notes.count) Notes")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .navigationTitle("Notes")
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
//        swipe delet yapabilmek için list'e çevirilicek
        List {
            ForEach(viewModel.notes) { note in
                NoteRow(note: note)
            }
            .onDelete(perform: { IndexSet in
                viewModel.deleteWhenSwipe(IndexSet)
            })
        }
        .toolbar {
            Button("Add", systemImage: "plus") {
                router.push(.sheets)
            }
        }
    }
}

