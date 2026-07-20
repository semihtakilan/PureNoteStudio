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
    
    var categories: [Category] = []
    
    init(note: Note, categoryRepository: CategoryRepository) {
        self.note = note
        self.categoryRepository = categoryRepository
    }
    
    func load() {
        do {
            categories = try categoryRepository.fetchAll()
        } catch {
            print("Category load error \(error)")
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
    
    func moveNote(to category: Category) {
        note.category = category
        category.notes.append(note)
    }
}
