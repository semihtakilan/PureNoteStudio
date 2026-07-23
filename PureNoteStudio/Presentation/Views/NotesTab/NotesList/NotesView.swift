//
//  NotesView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 28.06.2026.
//

import SwiftUI
import SwiftData

struct NotesView: View {
    @Bindable var viewModel: NotesViewModel
    
    @Environment(NotesRouter.self)
    var router

    var body: some View {

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
        .overlay(alignment: .bottomTrailing) {
            OverlayButton(imageName: "square.and.pencil") {
                router.presentedSheet = .addNote
            }
        }
        .navigationTitle("Notes")
        .task {
            viewModel.load()
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
}
