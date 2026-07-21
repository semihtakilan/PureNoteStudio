//
//  MoveToFolder.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 19.07.2026.
//

import SwiftUI

struct MoveToFolder: View {
    @State private var viewModel: MoveToFolderViewModel
    
    @Environment(NotesRouter.self)
    private var router
    
    init(
        note: Note,
        categoryRepository: CategoryRepository
    ) {
        self._viewModel = State(
            initialValue: MoveToFolderViewModel(
                note: note,
                categoryRepository: categoryRepository
            )
        )
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.items) { item in
                    Button {
                        viewModel.moveNote(to: item)
                        router.pop()
                    } label: {
                        HStack {
                            Image(systemName: item == .uncategorized ? "tray" : "folder.fill")
                            
                            Text(item.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            if case .folder(let category) = item {
                                Text(category.notes.count.description)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle("Select Folder")
        .task {
            viewModel.load()
        }
    }
}
