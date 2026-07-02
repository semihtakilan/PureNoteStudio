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

extension Date {
    var formattedDateString: String {
        let formatter = DateFormatter()
        let dayPassed = Calendar.current.dateComponents(Set([.day]), from: self, to: Date()).day ?? 0
        
        if Calendar.current.isDateInToday(self) {
            formatter.dateFormat = "hh:mm a"
            return formatter.string(from: self)
        } else if Calendar.current.isDateInYesterday(self) {
            formatter.dateStyle = .medium
            formatter.doesRelativeDateFormatting = true
            return formatter.string(from: self)
        } else if dayPassed >= 6 {
            return self.formatted(.dateTime.weekday(.wide))
        } else {
            return self.formatted(.dateTime.month(.abbreviated).day(.twoDigits))
        }
    }
}
