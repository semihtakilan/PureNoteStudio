//
//  NotesViewModelTests.swift
//  PureNoteStudioTests
//
//  Created by Batuhan Baran on 24.07.2026.
//

@testable
import PureNoteStudio
import SwiftData
import Testing
import Foundation

final class MockCategoryRepository: CategoryRepository {

    // Test tarafından doldurulacak "veritabanı" simülasyonu
    var categories: [PureNoteStudio.Category] = []

    // Spy: hangi metod kaç kere, hangi parametrelerle çağrıldı
    private(set) var fetchAllCallCount = 0
    private(set) var addCategoryCallCount = 0
    private(set) var lastAddedCategoryName: String?
    private(set) var assignNoteCallCount = 0
    private(set) var removeFromCategoryCallCount = 0
    private(set) var deleteCallCount = 0
    private(set) var saveCallCount = 0

    // Hata simülasyonu için
    var errorToThrow: Error?

    func fetchAll() throws -> [PureNoteStudio.Category] {
        fetchAllCallCount += 1
        if let errorToThrow { throw errorToThrow }
        // Gerçek repo: name'e göre sıralı
        return categories.sorted { $0.name < $1.name }
    }

    func addCategory(_ name: String) throws {
        addCategoryCallCount += 1
        lastAddedCategoryName = name
        if let errorToThrow { throw errorToThrow }
        let newCategory = Category(name: name)
        categories.append(newCategory)
        try save()
    }

    func assignNote(_ note: Note, _ category: PureNoteStudio.Category) throws {
        assignNoteCallCount += 1
        if let errorToThrow { throw errorToThrow }
        note.category = category
        try save()
    }

    func removeFromCategory(_ note: Note, _ category: PureNoteStudio.Category) throws {
        removeFromCategoryCallCount += 1
        if let errorToThrow { throw errorToThrow }
        note.category = nil
        try save()
    }

    func delete(_ category: PureNoteStudio.Category) throws {
        deleteCallCount += 1
        if let errorToThrow { throw errorToThrow }
        categories.removeAll { $0.id == category.id }
        try save()
    }

    func save() throws {
        saveCallCount += 1
        if let errorToThrow { throw errorToThrow }
    }
}

final class MockNoteRepository: NoteRepository {

    // Test tarafından doldurulacak "veritabanı" simülasyonu
    var notes: [Note] = []

    // Spy: hangi metod kaç kere, hangi parametrelerle çağrıldı
    private(set) var fetchAllCallCount = 0
    private(set) var searchCallCount = 0
    private(set) var lastSearchQuery: String?
    private(set) var addCallCount = 0
    private(set) var updateCallCount = 0
    private(set) var deleteCallCount = 0
    private(set) var filterCallCount = 0
    private(set) var lastFilterValue: String?
    private(set) var saveCallCount = 0

    // Hata simülasyonu için
    var errorToThrow: Error?

    func fetchAll() throws -> [Note] {
        fetchAllCallCount += 1
        if let errorToThrow { throw errorToThrow }
        // Gerçek repo: lastEdit'e göre reverse sıralı
        return notes.sorted { $0.lastEdit > $1.lastEdit }
    }

    func search(matching query: String) throws -> [Note] {
        searchCallCount += 1
        lastSearchQuery = query
        if let errorToThrow { throw errorToThrow }
        return notes
            .filter {
                $0.title.localizedStandardContains(query) ||
                $0.contentText.localizedStandardContains(query)
            }
            .sorted { $0.lastEdit > $1.lastEdit }
    }

    func add(_ note: Note) throws {
        addCallCount += 1
        if let errorToThrow { throw errorToThrow }
        notes.append(note)
        try save()
    }

    func update(_ note: Note) throws {
        updateCallCount += 1
        if let errorToThrow { throw errorToThrow }
        try save()
    }

    func delete(_ note: Note) throws {
        deleteCallCount += 1
        if let errorToThrow { throw errorToThrow }
        notes.removeAll { $0.id == note.id }
        try save()
    }

    func filter(_ filter: String) -> [Note] {
        filterCallCount += 1
        lastFilterValue = filter
        // Gerçek repo hata olsa bile fırlatmıyor, boş dizi dönüyor.
        // Mock da aynı davranışı taklit ediyor.
        return notes.filter { $0.category?.name == filter }
    }

    func save() throws {
        saveCallCount += 1
        if let errorToThrow { throw errorToThrow }
    }
}

struct NotesViewModelTests {

    let mockNoteRepository = MockNoteRepository()
    let mockCategoryRepository = MockCategoryRepository()
    let sut: NotesViewModel

    init() {
        self.sut = .init(
            noteRepository: mockNoteRepository,
            categoryRepository: mockCategoryRepository
        )
    }

    @Test
    func testLoad() async throws {
        await sut.load()
        #expect(mockCategoryRepository.fetchAllCallCount == 1)
        #expect(!sut.categoryFilters.isEmpty)
        #expect(!sut.chipDatas.isEmpty)
    }
    
    @Test
    func testHandleChipChange() async throws {
        let chip = ChipData(name: "All")
        await sut.handleChipChange(chip)
        #expect(sut.selectedChip == chip)
    }
}
