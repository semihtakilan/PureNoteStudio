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
        @Bindable var bindableViewModel = viewModel

        Group {
            switch viewModel.state {
            case .idle:
                ProgressView()
            case .success:
                if viewModel.showEmptyView {
                    ContentUnavailableView(
                        "Henüz veri yok",
                        systemImage: "tray",
                        description: Text("İlk notunuzu eklemek için sağ alttaki butona dokunun")
                    )
                } else {
                    successView
                }
            case .error(let message):
                ContentUnavailableView(
                    "Bir hata oluştu",
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
            }
        }
        .sheet(item: $router.presentedSheet, content: { item in
            switch item {
            case .addNote:
                AddNoteSheet(noteRepository: appDependencies.noteRepository)
                    .onDisappear {
                        viewModel.load()
                    }
            }
        })
        .overlay(alignment: .bottomTrailing) {
            addNoteButton
        }
        .navigationTitle("Notes")
        .task {
            viewModel.load()
        }
        .navigationDestination(for: NotesRoute.self) { route in
            switch route {
                
            case .detail(let note):
                NoteDetailView(
                    note: note,
                    noteRepository: appDependencies.noteRepository,
                    categoryRepository: appDependencies.categoryRepository
                )
                
            case .folders:
                FoldersView(
                    noteRepository: appDependencies.noteRepository,
                    categoryRepository: appDependencies.categoryRepository,
                    selectedItem: $bindableViewModel.selectedFilter
                )
                
            case .moveToFolder(let note):
                MoveToFolder(
                    note: note,
                    categoryRepository: appDependencies.categoryRepository
                )
            }
        }
    }

    private var successView: some View {
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
                    .onChange(of: viewModel.selectedChip) { _, newValue in
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

            // MARK: - NoteList
            noteListView()
                .padding(.horizontal, 8)
        }
        .background(Color(.systemGray6))
    }

    private var addNoteButton: some View {
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
        .padding(.trailing, 16)
        .padding(.bottom, 16)
    }
}
