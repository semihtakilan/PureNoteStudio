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
    private var router
    
    init(categoryRepository: CategoryRepository) {
        self._viewModel = State(
            initialValue: FoldersViewModel(categoryRepository: categoryRepository)
        )
    }
    
    var body: some View {
        VStack {
            
            // MARK: - FoldersRow
            List {
                FolderRow(category: Category(name: "All"))
                
                ForEach(viewModel.categories) { category in
                    FolderRow(category: category)
                }
                .onDelete { IndexSet in
                    viewModel.deleteWhenSwipe(IndexSet)
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

extension FoldersView {
    func FolderRow(category: Category) -> some View {
        Button {
            router.pendingSelectedChipName = category.name
            router.pop()
        } label: {
            HStack {
                Image(systemName: "folder.fill")
                
                Text(category.name)
                    .font(.headline)
                
                Spacer()
                
                Text(category.notes.count.description)
            }
        }
        .foregroundColor(.primary)
        
    }
}
