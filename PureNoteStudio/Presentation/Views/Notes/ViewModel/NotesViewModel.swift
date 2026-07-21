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

    var items: [CategoryFilter] = []
    var selectedFilter: CategoryFilter? = nil
    var searchText: String = ""

    var state: ViewState<[Note]> = .idle

    var notes: [Note] {
        if case .success(let notes) = state { return notes }
        return []
    }

    var showEmptyView: Bool {
        if case .success(let notes) = state {
            return notes.isEmpty && items.isEmpty // Geçici
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
            let categories = try categoryRepository.fetchAll()

            var filters: [CategoryFilter] = [.all]
            filters.append(contentsOf: categories.map{ .folder($0) })
            if !categories.isEmpty {
                filters.append(.uncategorized)
            }
            
            self.items = filters

            if let current = selectedFilter,
               let matched = items.first(where: { $0.name == current.name }) {
                selectedFilter = matched
                handleChipChange(matched)
            } else {
                self.selectedFilter = items.first
                state = .success(fetchedNotes)
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func handleChipChange(_ filter: CategoryFilter) {
        do {
            let filtered: [Note]

            switch filter {
            case .all:
                filtered = try noteRepository.fetchAll()
            case .uncategorized:
                let allNotes = try noteRepository.fetchAll()
                filtered = allNotes.filter { $0.category == nil }
            case .folder(let category):
                filtered = noteRepository.filter(category.name)
            }

            state = .success(filtered)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

//    func resolvePendingChip(router: NotesRouter) {
//        if let folderName = router.pendingSelectedChipName,
//           let matchedChip = items.first(where: { $0.name == folderName }) {
//
//            selectedFilter = matchedChip
//            handleChipChange(folderName)
//            router.pendingSelectedChipName = nil
//        }
//    }

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


