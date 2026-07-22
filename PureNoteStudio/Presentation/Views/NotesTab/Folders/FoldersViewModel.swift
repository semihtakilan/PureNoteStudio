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
    
    var items: [CategoryFilter] = []
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
            let categories = try categoryRepository.fetchAll()
            let fetchedNotes = try noteRepository.fetchAll()
            
            totalNotesCount = fetchedNotes.count
            uncategorizedNotesCount = fetchedNotes.filter { $0.category == nil }.count
            
            self.items = categories.map{ .folder($0) }
            
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
