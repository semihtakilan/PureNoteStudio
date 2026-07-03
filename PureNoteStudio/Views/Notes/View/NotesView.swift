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
                .onChange(of: viewModel.selectedChip) { oldValue, newValue in
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
        }
        
//        ScrollView {
//            LazyVStack(spacing: 8) {
//                ForEach(viewModel.notes) { note in
//                    NoteRow(note: note)
//                    
//                    if note.id != viewModel.notes.last?.id {
//                        Divider()
//                            .padding(.leading, 10)
//                    }
//                }
//            }
//            .padding(.vertical, 8)
//            .background(.white)
//            .clipShape(RoundedRectangle(cornerRadius: 16))
//            
            
//        }
//        .scrollIndicators(.hidden)
    }
}

