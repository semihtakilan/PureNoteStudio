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
        Group {
            switch viewModel.state {
            case .idle:
                Color.red
            case .success(let _):
                if viewModel.showEmptyView {
                    ContentUnavailableView("Henüz veri yok", image: "tray")
                } else {
                    successView
                }
            case .error:
                ContentUnavailableView("Error", image: "Error!!!")
            }
        }
        .onAppear{
            viewModel.load()
        }
        .navigationTitle("Notes")
        .task {
            viewModel.load()
        }
    }
    
    var successView: some View {
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
                viewModel.resolvePendingChip(router: router)
            }
            .onChange(of: router.pendingSelectedChipName) { _, _ in
                viewModel.resolvePendingChip(router: router)
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

        .background(Color(.systemGray6))
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
    
}
