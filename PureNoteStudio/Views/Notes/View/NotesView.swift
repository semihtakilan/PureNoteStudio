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
        VStack(spacing: 16) {
            // MARK: - SearchBar
            SearchBarView(searchText: $viewModel.searchText)
            .padding(.leading, 8)
            
            // MARK: - Categories
            ChipView(chipDatas: viewModel.chipDatas, selectedChip: $viewModel.selectedChip)
                .onChange(of: viewModel.selectedChip?.name ?? "All") { oldValue, newValue in
                    viewModel.handleChipChange(newValue)
                }
                .padding(.leading, 8)
            
            // MARK: - NoteList
            noteListView()
            
            Text("\(viewModel.notes.count) Notes")
                .font(.footnote)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding()
            
        }
        .navigationTitle("Notes")
        .task {
            viewModel.load()
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .center
        )
    }
    
}

extension NotesView {
    
    @ViewBuilder
    func noteListView() -> some View {
        List {
            ForEach(viewModel.notes) { note in
                NoteRow(note: note)
            }
            .onDelete(perform: { IndexSet in
                viewModel.deleteWhenSwipe(IndexSet)
            })
        }
        .listStyle(.plain)
        .toolbar {
            Button("Add", systemImage: "plus") {
                router.push(.sheets)
            }
        }
    }
}

