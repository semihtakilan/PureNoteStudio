//
//  MoveToFolderViewModel.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 20.07.2026.
//

import Foundation

@MainActor
@Observable
final class MoveToFolderViewModel {
    private let note: Note
    private let categoryRepository: CategoryRepository
    
    var items: [CategoryFilter] = []
    var errorMessage: String?
    
    init(note: Note, categoryRepository: CategoryRepository) {
        self.note = note
        self.categoryRepository = categoryRepository
    }
    
    func load() {
        do {
            let categories = try categoryRepository.fetchAll()
            var filter: [CategoryFilter] = categories.map{ .folder($0) }
            filter.append(.uncategorized)
            
            self.items = filter
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteWhenSwipe(_ indexSet: IndexSet) {
        guard let index = indexSet.first,
              let item = items.get(index)
        else { return }

        if case .folder(let category) = item {
            do {
                try categoryRepository.delete(category)
                load()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func moveNote(to filter: CategoryFilter) -> Bool {
        do {
            switch filter {
            case .folder(let category):
                try categoryRepository.assignNote(note, category)
            case .uncategorized:
                if let category = note.category {
                    try categoryRepository.removeFromCategory(note, category)
                }
            case .all:
                return false
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
