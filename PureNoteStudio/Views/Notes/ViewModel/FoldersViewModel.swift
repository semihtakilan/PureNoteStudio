//
//  FoldersViewModel.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 16.07.2026.
//

import Foundation

@Observable
final class FoldersViewModel {
    private let noteRepository: NoteRepository
    private let categoryRepository: CategoryRepository
    
    var categories: [CategoryFilter] = []
    var categoryData: [Category] = []
    var totalNotesCount: Int = 0
    var uncategorizedNotesCount: Int = 0
    
    var presentedAlert: Bool = false
    var categoryName: String = ""
    
    init(noteRepository: NoteRepository, categoryRepository: CategoryRepository) {
        self.noteRepository = noteRepository
        self.categoryRepository = categoryRepository
    }
    
    func load() {
        do {
            let data = try categoryRepository.fetchAll()
            let fetchedNotes = try noteRepository.fetchAll()
            self.categories = CategoryFilter.allCases(from: data)
            self.categoryData = data
        } catch {
            print("Category load error \(error)")
        }
    }
    
    func deleteWhenSwipe(_ indexSet: IndexSet) {
        guard let index = indexSet.first,
              let filter = categories.get(index),
              case .custom(let category) = filter
        else { return }

        do {
            try categoryRepository.delete(category)
            load()
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
