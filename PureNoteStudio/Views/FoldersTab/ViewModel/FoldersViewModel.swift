//
//  FoldersViewModel.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 14.07.2026.
//

import Foundation

@Observable
final class FoldersViewModel {
    private let categoryRepository: CategoryRepository
    
    var categories: [Category] = []
    
    var presentedAlert: Bool = false
    var categoryName: String = ""
    
    init(categoryRepository: CategoryRepository) {
        self.categoryRepository = categoryRepository
    }
    
    func load() {
        do {
            categories = try categoryRepository.fetchAll()
        } catch {
            print("Category fetch error: \(error)")
        }
    }
    
    func deleteWhenSwipe(_ indexSet: IndexSet) {
        guard let index = indexSet.first,
              let category = categories.get(index)
        else { return }
        do {
            try categoryRepository.delete(category)
            categories = try categoryRepository.fetchAll()
        } catch {
            print("Category delete error \(error)")
        }
    }
    
    func alertCancel() {
        presentedAlert = false
        categoryName = ""
    }
    
    func addCategory() {
        do {
            try categoryRepository.addCategory(categoryName)
        } catch {
            print("Category add error: \(error)")
        }
        presentedAlert = false
        categoryName = ""
        
        load()
    }

}
