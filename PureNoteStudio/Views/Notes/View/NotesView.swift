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
    
    @Environment(AppDependencies.self)
    private var appDependencies
    
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
                .padding(.horizontal, 8)
            
            // MARK: - Categories
            HStack {
                ChipView(chipDatas: viewModel.chipDatas, selectedChip: $viewModel.selectedChip)
                    .onChange(of: viewModel.selectedChip?.name ?? "All") { oldValue, newValue in
                        viewModel.handleChipChange(newValue)
                    }
                
                Button {
                    router.push(.folders)
                } label: {
                    Image(systemName: "folder")
                }
                .padding(8)
                .padding(.horizontal, 8)
                .font(.headline)
                .foregroundStyle(.primary)
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 8)
            .onAppear {
                resolvePendingChip()
            }
            .onChange(of: router.pendingSelectedChipName) { _, _ in
                resolvePendingChip()
            }
            
            // MARK: - NoteList
            noteListView()
                .padding(.horizontal, 8)
            
            // MARK: - NotesCount
            
            
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
        .onAppear{
            viewModel.load()
        }
        .navigationTitle("Notes")
        .task {
            viewModel.load()
        }
        .background(Color(.systemGray6))
        .sheet(item: $router.presentedSheet, content: { item in
            switch item {
            case .addNote:
                AddNoteSheet(noteRepository: appDependencies.noteRepository)
                    .onDisappear{
                        viewModel.load()
                    }
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
            
            Text("\(viewModel.notes.count.description) Notes")
                .font(.footnote)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func resolvePendingChip() {
        if let folderName = router.pendingSelectedChipName,
           let matchedChip = viewModel.chipDatas.first(where: { $0.name == folderName }) {
            
            viewModel.selectedChip = matchedChip
            viewModel.handleChipChange(folderName)
            router.pendingSelectedChipName = nil
        }
    }
}
