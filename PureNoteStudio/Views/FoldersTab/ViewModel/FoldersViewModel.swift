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
    private let rowHeight: CGFloat = 52
    private let maxVisibleRows = 5
    
    var categories: [Category] = []
    
    var listHeight: CGFloat {
            let visibleRowCount = min(categories.count, maxVisibleRows)
            return CGFloat(visibleRowCount) * rowHeight
        }
    
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

}
