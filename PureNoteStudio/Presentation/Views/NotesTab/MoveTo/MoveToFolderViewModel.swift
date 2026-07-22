//
//  MoveToFolderViewModel.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 20.07.2026.
//

import Foundation

@Observable
final class MoveToFolderViewModel {
    private let note: Note
    private let categoryRepository: CategoryRepository
    
    var items: [CategoryFilter] = []
    
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
            print("Category load error \(error)")
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
                print("Category delete error \(error)")
            }
        }
    }
    
    func moveNote(to filter: CategoryFilter) {
        switch filter {
        case .folder(let category):
            note.category = category
            category.notes.append(note)
        case .uncategorized:
            note.category = nil
        case .all:
            break
        }
    }
}
