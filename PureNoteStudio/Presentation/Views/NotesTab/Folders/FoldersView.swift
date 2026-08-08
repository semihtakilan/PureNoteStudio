//
//  FoldersView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 16.07.2026.
//

import SwiftUI

struct FoldersView: View {
    let onFilterSelected: (CategoryFilter) -> Void
    
    @Environment(AppDependencies.self)
    private var dependencies
    
    @State private var viewModel: FoldersViewModel?
    
    var body: some View {
        Group {
            if let viewModel {
                FoldersContentView(viewModel: viewModel, onFilterSelected: onFilterSelected)
            } else {
                ProgressView()
            }
        }
        .task {
            if viewModel == nil {
                viewModel = FoldersViewModel(
                    noteRepository: dependencies.noteRepository,
                    categoryRepository: dependencies.categoryRepository
                )
            }
        }
    }
}

struct FoldersContentView: View {
    @Bindable var viewModel: FoldersViewModel
    let onFilterSelected: (CategoryFilter) -> Void
    
    @Environment(NotesRouter.self)
    var router
    
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
        .background(Color.appPageBackground)
        .alert("Bir hata oluştu", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
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
