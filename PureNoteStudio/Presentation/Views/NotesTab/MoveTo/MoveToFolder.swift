//
//  MoveToFolder.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 19.07.2026.
//

import SwiftUI

struct MoveToFolder: View {
    let note: Note
    
    @Environment(AppDependencies.self)
    private var dependencies
    
    @State private var viewModel: MoveToFolderViewModel?
    
    var body: some View {
        Group {
            if let viewModel {
                MoveToFolderContentView(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .task {
            if viewModel == nil {
                viewModel = MoveToFolderViewModel(
                    note: note,
                    categoryRepository: dependencies.categoryRepository
                )
            }
        }
    }
}

struct MoveToFolderContentView: View {
    @Bindable var viewModel: MoveToFolderViewModel
    
    @Environment(NotesRouter.self)
    private var router
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.items) { item in
                    Button {
                        if viewModel.moveNote(to: item) {
                            router.pop()
                        }
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
        .scrollContentBackground(.hidden)
        .background(Color.appPageBackground)
        .navigationTitle("Select Folder")
        .task {
            viewModel.load()
        }
        .alert("Bir hata oluştu", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
