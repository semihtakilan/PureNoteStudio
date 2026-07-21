//
//  FoldersView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 16.07.2026.
//

import SwiftUI

struct FoldersView: View {
    @State private var viewModel: FoldersViewModel
    
    @Environment(NotesRouter.self)
    var router
    
    init(noteRepository: NoteRepository, categoryRepository: CategoryRepository) {
        self._viewModel = State(
            initialValue: FoldersViewModel(noteRepository: noteRepository, categoryRepository: categoryRepository)
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
            
            // MARK: - AddFolderButton
            Button {
                viewModel.presentedAlert = true
            } label: {
                Image(systemName: "folder.badge.plus")
            }
            .padding(10)
            .font(.system(size: 20))
            .bold()
            .foregroundColor(.white)
            .background(Color(.systemBlue))
            .clipShape(Circle())
            .frame(minWidth: 0, maxWidth: .infinity ,alignment: .trailing)
            .padding(.trailing, 16)
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
        .navigationTitle("Folders")
        .task {
            viewModel.load()
        }
        .background(Color(.systemGray6))
    }
}


