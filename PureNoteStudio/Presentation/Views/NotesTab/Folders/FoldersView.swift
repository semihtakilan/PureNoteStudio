//
//  FoldersView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 16.07.2026.
//

import SwiftUI

struct FoldersView: View {
    @State private var viewModel: FoldersViewModel
    @Binding var selectedItem: CategoryFilter?
    
    @Environment(NotesRouter.self)
    var router
    
    init(
        noteRepository: NoteRepository,
        categoryRepository: CategoryRepository,
        selectedItem: Binding<CategoryFilter?>
    ) {
        self._selectedItem = selectedItem
        self._viewModel = State(
            initialValue: FoldersViewModel(
                noteRepository: noteRepository,
                categoryRepository: categoryRepository
            )
        )
    }
    
    var body: some View {
        VStack {
            
            // MARK: - FoldersRow
            List {
                FolderRow(item: .all, customCount: viewModel.totalNotesCount)
                
                ForEach(viewModel.items) { item in
                    FolderRow(item: item)
                }
                .onDelete { IndexSet in
                    viewModel.deleteWhenSwipe(IndexSet)
                }
                
                if !viewModel.items.isEmpty {
                    FolderRow(
                        item: .uncategorized,
                        customCount: viewModel.uncategorizedNotesCount
                    )
                }
            }
        }
        .navigationTitle("Folders")
        .task {
            viewModel.load()
        }
        .background(Color(.systemGray6))
        .overlay(alignment: .bottomTrailing) {
            OverlayButton(imageName: "folder.badge.plus") {
                viewModel.presentedAlert = true
            }
            .alert("New Folder", isPresented: $viewModel.presentedAlert) {
                TextField("Unnamed folder", text: $viewModel.categoryName)
                
                Button("Cancel", role: .cancel) {
                    viewModel.alertCancel()
                }
                Button("OK") {
                    viewModel.addCategory()
                }
            }
        }
    }
}


