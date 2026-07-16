//
//  FoldersView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 28.06.2026.
//

import SwiftUI

struct FoldersView: View {
    @Environment(FoldersRouter.self)
    private var router
    
    @State private var viewModel: FoldersViewModel
    
    init(categoryRepository: CategoryRepository) {
        self._viewModel = State(
            initialValue: FoldersViewModel(categoryRepository: categoryRepository)
        )
    }
    
    var body: some View {
        @Bindable var router = router
        
        VStack(spacing: 16) {
            
            // MARK: - CategoriesList
            List {
                ForEach(viewModel.categories) { category in
                    CategoryRow(category: category)
                }
                .onDelete { IndexSet in
                    viewModel.deleteWhenSwipe(IndexSet)
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 8)
            
            // MARK: - AddCategoryButton
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
