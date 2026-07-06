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
            
            // MARK: - Categories
            ChipView(chipDatas: viewModel.chipDatas, selectedChip: $viewModel.selectedChip)
                .onChange(of: viewModel.selectedChip?.name ?? "All") { oldValue, newValue in
                    viewModel.handleChipChange(newValue)
                }
            // MARK: - NoteList
            noteListView()
            
            // MARK: - NotesCount
            Text("\(viewModel.notes.count) Notes")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            // MARK: - AddNoteButton
            Button {
                viewModel.isAddNoteSheetPresented.toggle()
                print(viewModel.isAddNoteSheetPresented)
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .padding(8)
            .font(.subheadline)
            .foregroundColor(.white)
            .background(Color(.systemBlue))
            .clipShape(Circle())
            .frame(minWidth: 0, maxWidth: .infinity ,alignment: .trailing)
        }
        .navigationTitle("Notes")
        .padding(.horizontal)
        .task {
            viewModel.load()
        }
        .background(Color(.systemGray6))
        .sheet(isPresented: $viewModel.isAddNoteSheetPresented) {
            AddNoteSheet { title, content in
                try viewModel.saveNote(title: title, content: content)
            }
        }
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
        .toolbar {
            Button("Add", systemImage: "plus") {
            }
        }
    }
}
