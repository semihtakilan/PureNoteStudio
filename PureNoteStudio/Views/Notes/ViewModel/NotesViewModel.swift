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
    private(set) var noteRepository: NoteRepository
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
            
            chipDatas = [ChipData(name: "All")] + categories.map { category in
                ChipData(name: category.name)
            }
            
            if let currentChip = selectedChip,
               let matched = chipDatas.first(where: { $0.name == currentChip.name }) {
                selectedChip = matched
                handleChipChange(matched.name)
            } else {
                self.selectedChip = chipDatas.first
                self.notes = try noteRepository.fetchAll()
            }
        } catch {
            print("Bir şeyler patladı!!! \(error)")
        }
    }
    
    func handleChipChange(_ newValue: String) {
        if newValue == "All" {
            do {
                notes = try noteRepository.fetchAll()
            } catch {
            }
        } else {
            notes = noteRepository.filter(chip: newValue)
        }
    }
    
    func resolvePendingChip(router: NotesRouter) {
        if let folderName = router.pendingSelectedChipName,
           let matchedChip = chipDatas.first(where: { $0.name == folderName }) {
            
            selectedChip = matchedChip
            handleChipChange(folderName)
            router.pendingSelectedChipName = nil
        }
    }
    
    func deleteWhenSwipe(_ indexSet: IndexSet) {
        guard let index = indexSet.first,
              let note = notes.get(index)
        else { return }
        do {
            try noteRepository.delete(note)
            notes = try noteRepository.fetchAll()
        } catch {
            print("silemedik \(error)")
        }
    }
    
    func searchWhenWritten(_ newValue: String) {
        let searchText = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !searchText.isEmpty else {
            load()
            return
        }
        
        do {
            notes = try noteRepository.search(matching: searchText)
        } catch {
            print("Ararken kaybolduk!!! \(error)")
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else {
            assertionFailure("Index \(index) out of bounds")
            return nil
        }
        return self[index]
    }
    
    func get(_ index: Index) -> Element? {
        self[safe: index]
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
        } else if dayPassed < 6 {
            return self.formatted(.dateTime.weekday(.wide))
        } else {
            return self.formatted(.dateTime.month(.abbreviated).day(.twoDigits))
        }
    }
}

