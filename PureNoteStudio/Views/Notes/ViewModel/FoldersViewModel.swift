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
    
    var categories: [Category] = []
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
            categories = try categoryRepository.fetchAll()
            
            let allNotes = try noteRepository.fetchAll()
            totalNotesCount = allNotes.count
            uncategorizedNotesCount = allNotes.filter { $0.category == nil }.count
            
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
