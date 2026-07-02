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
    
    var selectedChip: ChipData? = nil
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
            chipDatas = fetchAllChipDatas(from: categories)
        } catch {
            print("Bir şeyler patladı!!!")
        }
    }
    
    func convertCategoryToChipData(category: Category) -> ChipData {
        return .init(name: category.name, createdOn: category.createdOn)
    }
    
    func fetchAllChipDatas(from categories: [Category]) -> [ChipData] {
        var chipDatas: [ChipData] = []
        
        for category in categories {
            chipDatas.append(self.convertCategoryToChipData(category: category))
        }
        
        return chipDatas
    }
    
    func didTapChip(_ chip: ChipData) {
        if selectedChip?.id == chip.id {
            selectedChip = nil
        } else {
            selectedChip = chip
        }
        
        
    }
}
