//
//  NotesViewModel.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 1.07.2026.
//

import SwiftUI
import SwiftData

// MARK: - Sabit (fixed) case'ler
enum FixedCategory: String, CaseIterable, Identifiable {
    case all
    case uncategorized

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .uncategorized: return "Uncategorized"
        }
    }
}

// MARK: - Filtre enum'u (sabit + dinamik kategoriler)
enum CategoryFilter: Hashable, Identifiable {
    case fixed(FixedCategory)
    case custom(Category)

    var id: String {
        switch self {
        case .fixed(let f): return f.id
        case .custom(let c): return c.persistentModelID.storeIdentifier ?? c.name
        }
    }

    var title: String {
        switch self {
        case .fixed(let f): return f.title
        case .custom(let c): return c.name
        }
    }

    var canDelete: Bool {
        if case .custom = self { return true }
        return false
    }

    static let all: CategoryFilter = .fixed(.all)
    static let uncategorized: CategoryFilter = .fixed(.uncategorized)

    static func allCases(from categories: [Category]) -> [CategoryFilter] {
        guard !categories.isEmpty else { return [.all] }
        return [.all] + categories.map(CategoryFilter.custom) + [.uncategorized]
    }
}

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

    var notes: [Note] {
        if case .success(let notes) = state { return notes }
        return []
    }

    var showEmptyView: Bool {
        if case .success(let notes) = state {
            return notes.isEmpty && categories.isEmpty
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

    @MainActor
    func load() {
        do {
            let fetchedNotes = try noteRepository.fetchAll()
            categories = try categoryRepository.fetchAll()

            chipDatas = CategoryFilter.allCases(from: categories).map(ChipData.init)

            if let currentChip = selectedChip,
               let matched = chipDatas.first(where: { $0.name == currentChip.name }) {
                selectedChip = matched
                handleChipChange(matched.filter)
            } else {
                selectedChip = chipDatas.first
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
            case .fixed(.all):
                filtered = try noteRepository.fetchAll()
            case .fixed(.uncategorized):
                let allNotes = try noteRepository.fetchAll()
                filtered = allNotes.filter { $0.category == nil }
            case .custom(let category):
                filtered = noteRepository.filter(chip: category.name)
            }

            state = .success(filtered)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

//    func resolvePendingChip(router: NotesRouter) {
//        if let folderName = router.pendingSelectedChipName,
//           let matchedChip = chipDatas.first(where: { $0.name == folderName }) {
//
//            selectedChip = matchedChip
//            handleChipChange(matchedChip.filter)
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
