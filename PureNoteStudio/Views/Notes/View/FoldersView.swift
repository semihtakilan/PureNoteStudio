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

    @Binding
    var selectedChip: ChipData?

    init(
        noteRepository: NoteRepository,
        categoryRepository: CategoryRepository,
        selectedChip: Binding<ChipData?>
    ) {
        self._viewModel = State(
            initialValue: FoldersViewModel(
                noteRepository: noteRepository,
                categoryRepository: categoryRepository
            )
        )
        self._selectedChip = selectedChip
    }
    
    var body: some View {
        VStack {
            
            // MARK: - FoldersRow
            List {
                ForEach(viewModel.categories) { category in
                    folderRow(category: category)
                        .swipeActions(edge: .trailing, allowsFullSwipe: category.canDelete) {
                            if category.canDelete {
                                Button(role: .destructive) {
                                    if let index = viewModel.categories.firstIndex(where: { $0.id == category.id }) {
                                        viewModel.deleteWhenSwipe(IndexSet(integer: index))
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
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
    func folderRow(category: CategoryFilter, customCount: Int? = nil) -> some View {
        Button {
            router.pop()
        } label: {
            HStack {
                Image(systemName: "folder.fill")
                
                Text(category.title)
                    .font(.headline)
                
                Spacer()
                
//                Text((customCount ?? category.notes.count).description)
            }
        }
        .foregroundColor(.primary)
        
    }
}
