//
//  NotesViewModel.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 1.07.2026.
//

import SwiftUI
import SwiftData

@Observable
final class NotesViewModel {
    private let noteRepository: NoteRepository
    private let categoryRepository: CategoryRepository
    
    var notes: [Note] = []
    var categories: [Category] = []
    var chipDatas: [ChipData] = []
    var selectedCategory: Category?
    var searchText: String = ""
    
    init(
        noteRepository: NoteRepository,
        categoryRepository: CategoryRepository
    ) {
        self.noteRepository = noteRepository
        self.categoryRepository = categoryRepository
    }
    
    func load() {
        do {
            notes = try noteRepository.fetchAll()
            categories = try categoryRepository.fetchAll()
            chipDatas = ChipData.fetchAll(from: categories)
        } catch {
            print("Bir şeyler patladı!!!")
        }
    }
}
