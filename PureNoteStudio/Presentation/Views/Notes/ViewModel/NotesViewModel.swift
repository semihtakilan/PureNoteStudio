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
            return notes.isEmpty && items.count <= 1 // Geçici
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
            let categories = try categoryRepository.fetchAll()

            var filters: [CategoryFilter] = [.all]
            filters.append(contentsOf: categories.map{ .folder($0) })
            if !categories.isEmpty {
                filters.append(.uncategorized)
            }
            
            self.items = filters

            if selectedFilter == nil {
                selectedFilter = .all
            } else if let current = selectedFilter, let matched = items.first(where: { $0.id == current.id }) {
                selectedFilter = matched
            }
            
            applyFilter()
            
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func handleChipChange(_ filter: CategoryFilter) {
        selectedFilter = filter
        applyFilter()
    }
    
    func searchWhenWritten(_ newValue: String) {
        searchText = newValue
        applyFilter()
    }
    
    func applyFilter() {
        do {
            let filter = selectedFilter ?? .all
            let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            var resultNotes: [Note] = []
            
            if !text.isEmpty {
                let searchResults = try noteRepository.search(matching: text)
                
                switch filter {
                case .all:
                    resultNotes = searchResults
                case .uncategorized:
                    resultNotes = searchResults.filter{ $0.category == nil }
                case .folder(let category):
                    resultNotes = searchResults.filter{ $0.category == category }
                }
            } else {
                switch filter {
                case .all:
                    resultNotes = try noteRepository.fetchAll()
                case .uncategorized:
                    let allNotes = try noteRepository.fetchAll()
                    resultNotes = allNotes.filter{ $0.category == nil }
                case .folder(let category):
                    let allNotes = try noteRepository.fetchAll()
                    resultNotes = allNotes.filter{ $0.category == category }
                }
            }
            
            state = .success(resultNotes)
            
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func deleteWhenSwipe(_ indexSet: IndexSet) {
        guard let index = indexSet.first,
              let note = notes.get(index)
        else { return }

        do {
            try noteRepository.delete(note)
            applyFilter()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

}


