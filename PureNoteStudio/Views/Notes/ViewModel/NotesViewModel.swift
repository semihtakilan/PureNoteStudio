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
    private let repository: NoteRepository
    
    var notes: [Note] = []
    var categories: [Category] = []
    var selectedCategory: Category?
    var searchText: String = ""
    
    init(repository: NoteRepository) {
        self.repository = repository
    }
    
    func load() {
        do {
            notes = try repository.fetchAll()
        } catch {
            print("HATA")
        }
    }

    func chipSelected(chip: Category) {
        print("First Selected: \(chip.name): \(chip.isSelected)")
        
        for category in categories {
            if chip != category {
                chip.isSelected = false
            } else {
                chip.isSelected.toggle()
            }
        }
        
        print("Last Selected: \(chip.name): \(chip.isSelected)")
    }
}
