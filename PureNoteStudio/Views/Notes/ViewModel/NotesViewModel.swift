//
//  NotesViewModel.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 1.07.2026.
//

import SwiftUI
import SwiftData

enum ViewState<T: Equatable>: Equatable {
    case idle
    case success(T)
    case error(String)
}

@Observable
final class NotesViewModel {
    private(set) var noteRepository: NoteRepository
    private let categoryRepository: CategoryRepository

    var categories: [Category] = []
    var chipDatas: [ChipData] = []

    var selectedChip: ChipData? = nil
    var searchText: String = ""

    var state: ViewState<[Note]> = .idle

    // Tek doğruluk kaynağı: state. notes artık ondan türetiliyor.
    var notes: [Note] {
        if case .success(let notes) = state { return notes }
        return []
    }

    var showEmptyView: Bool {
        if case .success(let notes) = state {
            return notes.isEmpty
        }
        return false
    }

    init(
        noteRepository: NoteRepository,
        categoryRepository: CategoryRepository
    ) {
        self.noteRepository = noteRepository
        self.categoryRepository = categoryRepository
    }

    func load() {
        do {
            let fetchedNotes = try noteRepository.fetchAll()
            categories = try categoryRepository.fetchAll()

            var chips = [ChipData(name: "All")]
            chips.append(contentsOf: categories.map { ChipData(name: $0.name) })

            if !categories.isEmpty {
                chips.append(ChipData(name: "Uncategorized"))
            }
            self.chipDatas = chips

            if let currentChip = selectedChip,
               let matched = chipDatas.first(where: { $0.name == currentChip.name }) {
                selectedChip = matched
                handleChipChange(matched.name)
            } else {
                self.selectedChip = chipDatas.first
                state = .success(fetchedNotes)
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func handleChipChange(_ newValue: String) {
        do {
            let filtered: [Note]

            if newValue == "All" {
                filtered = try noteRepository.fetchAll()
            } else if newValue == "Uncategorized" {
                let allNotes = try noteRepository.fetchAll()
                filtered = allNotes.filter { $0.category == nil }
            } else {
                filtered = noteRepository.filter(chip: newValue)
            }

            state = .success(filtered)
        } catch {
            state = .error(error.localizedDescription)
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
            let updated = try noteRepository.fetchAll()
            state = .success(updated)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func searchWhenWritten(_ newValue: String) {
        let searchText = newValue.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !searchText.isEmpty else {
            load()
            return
        }

        do {
            let results = try noteRepository.search(matching: searchText)
            state = .success(results)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
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
