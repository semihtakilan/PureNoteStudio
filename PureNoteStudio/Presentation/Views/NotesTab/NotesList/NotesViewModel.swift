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

    var chipDatas: [ChipData] = []
    var categoryFilters: [CategoryFilter] = []
    
    var selectedChip: ChipData? = nil
    var selectedFilter: CategoryFilter? = nil
    
    var searchText: String = ""

    var state: ViewState<[Note]> = .idle

    var notes: [Note] {
        if case .success(let notes) = state { return notes }
        return []
    }

    var showEmptyView: Bool {
        if case .success(let notes) = state {
            return notes.isEmpty && categoryFilters.count <= 1 // Geçici
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
            
            self.categoryFilters = filters
            self.chipDatas = categoryFilters.map({ category in
                return ChipData(
                    name: category.name
                )
            })

            
            if selectedFilter == nil {
                selectedFilter = .all
            } else if let current = selectedFilter, let matched = categoryFilters.first(where: { $0.id == current.id }) {
                selectedFilter = matched
            }
            
            selectedChip = ChipData(name: selectedFilter?.name ?? "")
            applyFilter()
            
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func handleChipChange(_ chip: ChipData?) {
        guard let chip else { return }
        selectedChip = chip
        selectedFilter = categoryFilters.first(where: { ($0.name == chip.name) })
        applyFilter()
    }
    
    func searchWhenWritten(_ newValue: String) {
        searchText = newValue
        applyFilter()
    }
    
    func applyFilter() {
        do {
            let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let baseNotes: [Note] = try text.isEmpty
            ? noteRepository.fetchAll()
            : noteRepository.search(matching: text)
            
            state = .success(filtered(baseNotes, by: selectedFilter ?? .all))
            
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    private func filtered(_ notes: [Note], by filter: CategoryFilter) -> [Note] {
        switch filter {
        case .all:
            return notes
        case .uncategorized:
            return notes.filter { $0.category == nil }
        case .folder(let category):
            return notes.filter { $0.category == category }
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


