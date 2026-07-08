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
        @Bindable var router = router
        VStack(spacing: 16) {
            // MARK: - SearchBar
            SearchBarView(searchText: $viewModel.searchText)
                .onChange(of: viewModel.searchText, { oldValue, newValue in
                    viewModel.searchWhenWritten(newValue)
                })
                .padding(.leading, 8)
            
            // MARK: - Categories
            ChipView(chipDatas: viewModel.chipDatas, selectedChip: $viewModel.selectedChip)
                .onChange(of: viewModel.selectedChip?.name ?? "All") { oldValue, newValue in
                    viewModel.handleChipChange(newValue)
                }
                .padding(.leading, 8)
            
            // MARK: - NoteList
            noteListView()
            
            // MARK: - NotesCount
            Text("\(viewModel.notes.count) Notes")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            // MARK: - AddNoteButton
            Button {
                router.presentedSheet = .addNote
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .padding(10)
            .font(.system(size: 20))
            .bold()
            .foregroundColor(.white)
            .background(Color(.systemBlue))
            .clipShape(Circle())
            .frame(minWidth: 0, maxWidth: .infinity ,alignment: .trailing)
            .padding(.trailing, 16)
        }
        .navigationTitle("Notes")
        .task {
            viewModel.load()
        }
        .background(Color(.systemGray6))
        .sheet(item: $router.presentedSheet, content: { item in
            switch item {
            case .addNote:
                AddNoteSheet(noteRepository: viewModel.noteRepository)
            }
        })
    }
}

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
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.vertical, 8)
    }
}
