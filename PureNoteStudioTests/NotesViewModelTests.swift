//
//  NotesViewModelTests.swift
//  PureNoteStudioTests
//
//  Created by Semih TAKILAN on 24.07.2026.
//

import Testing
import Foundation
@testable import PureNoteStudio

@Suite("NotesViewModelTests")
@MainActor
struct NotesViewModelTests {
    
    let sut: NotesViewModel
    let mockNoteRepository: MockNoteRepository
    let mockCategoryRepository: MockCategoryRepository
    
    init() {
        mockNoteRepository = MockNoteRepository()
        mockCategoryRepository = MockCategoryRepository()
        
        self.sut = NotesViewModel(
            noteRepository: mockNoteRepository,
            categoryRepository: mockCategoryRepository
        )
    }
    
    @Test("Computed Properties: Notes dizisi ve showEmptyView doğru hesaplanmalı")
    func test_computedProperties_stateLogic() {
        #expect(sut.notes.isEmpty == true)
        #expect(sut.showEmptyView == false)
        
        mockCategoryRepository.mockCategories = []
        mockNoteRepository.mockAllNotes = []
        sut.load()
        
        #expect(sut.notes.isEmpty == true)
        #expect(sut.showEmptyView == true)
    }
    
    @Test("load çalıştı kategori varsa Uncategorized eklenmeli")
    func test_loadCategories_shouldAppendUncategorizedFilter() {
        
        let category = PureNoteStudio.Category(name: "Work")
        mockCategoryRepository.mockCategories = [category]
        
        sut.load()
        
        #expect(mockCategoryRepository.fetchAllCallCount == 1)
        #expect(sut.categoryFilters.count == 3)
        #expect(sut.chipDatas.count == 3)
        #expect(sut.selectedFilter == .all)

    }
    
    @Test("load çalıştı kategori yoksa Uncategorized eklenmemeli")
    func test_loadCategories_shouldNotAppendUncategorizedFilter() {
        
        mockCategoryRepository.mockCategories = []
        
        sut.load()
        
        #expect(mockCategoryRepository.fetchAllCallCount == 1)
        #expect(sut.categoryFilters.count == 1)
        #expect(sut.chipDatas.count == 1)
        #expect(sut.selectedFilter == .all)
        
    }
    
    @Test("load çalıştı repo'dan hata gelirse viewState .error olmalı")
    func test_load_whenRepositoryThrows_shouldSetErrorState() {
        
        mockCategoryRepository.shouldThrowError = true
        mockCategoryRepository.mockError = NSError(
            domain: "Test",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Kategori Yüklenemedi"]
        )

        sut.load()
        
        #expect(sut.state == .error("Kategori Yüklenemedi"))
        
    }
    
    @Test("handleChipChange çalıştı geçerli chip seçilince filtre güncellenmeli")
    func test_handleChipChange_withValidFilter_shouldUpdateSelectedFilter() {
        
        let category = PureNoteStudio.Category(name: "İş")
        mockCategoryRepository.mockCategories = [category]
        sut.load()
        
        let chipToSelect = ChipData(name: "İş")
        
        sut.handleChipChange(chipToSelect)
        
        #expect(sut.selectedChip?.name == "İş")
        #expect(sut.selectedFilter?.name == "İş")
        #expect(mockNoteRepository.fetchAllCallCount == 2)
        
    }
    
    @Test("handleChipChange çalıştı nil gönderildiğinde işlem yapmadan çıkmalı")
    func test_handleChipChange_withNil_shouldReturnEarly() {
        sut.load()
        let initialFilter = sut.selectedFilter
        
        sut.handleChipChange(nil)
        
        #expect(sut.selectedFilter == initialFilter)
    }
    
    @Test("searchWhenWritten çalıştı dolu metin gönderildiğinde search çağrılmalı")
    func test_searchWhenWritten_withValidText_shouldCallSearch() {
        
        let query = "SearchText"
        mockNoteRepository.mockSearchedNotes = []
        
        sut.searchWhenWritten(query)
        
        #expect(sut.searchText == query)
        #expect(mockNoteRepository.searchCallCount == 1)
        #expect(mockNoteRepository.searchCapturedQuery == query)
    }
    
    @Test("searchWhenWritten boş metin gönderildiğinde fetchAll çağrılmalı")
    func test_searchWhenWritten_withEmptyText_shouldCallFetchAll() {
        mockNoteRepository.mockAllNotes = []
        
        sut.searchWhenWritten("   ")
        
        #expect(mockNoteRepository.searchCallCount == 0)
        #expect(mockNoteRepository.fetchAllCallCount == 1)
    }
    
    @Test("deleteWhenSwipe çalıştı geçerli index ile delete repo tetiklenmeli")
    func test_deleteWhenSwipe_withValidIndex_shouldCallDelete() {
        
        let noteToDelete = Note(title: "Silinecek", contentText: "Silinicek not diskte durmaz")
        mockNoteRepository.mockAllNotes = [noteToDelete]
        sut.load()
        
        let index = IndexSet(integer: 0)
        
        sut.deleteWhenSwipe(index)
        
        #expect(mockNoteRepository.deleteCallCount == 1)
        #expect(mockNoteRepository.deleteCapturedNote?.title == "Silinecek")
        
    }
    
    @Test("deleteWhenSwipe çalıştı geçersiz index verildiğinde işlem yapmamalı")
    func test_deleteWhenSwipe_withInvalidIndex_shouldDoNothing() {
        mockNoteRepository.mockAllNotes = []
        sut.load()
        
        let index = IndexSet(integer: 99)
        sut.deleteWhenSwipe(index)
        
        #expect(mockNoteRepository.deleteCallCount == 0)
    }
    
    @Test("deleteWhenSwipe çalıştı hata fırlatılırsa ViewState error olmalı")
    func test_deleteWhenSwipe_whenRepositoryThrows_shouldSetErrorState() {
        
        let note = Note(title: "Hatalı", contentText: "")
        mockNoteRepository.mockAllNotes = [note]
        sut.load()
        
        mockNoteRepository.shouldThrowError = true
        mockNoteRepository.mockError = NSError(
            domain: "Test",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Silinemedi"]
        )
        
        let index = IndexSet(integer: 0)
        sut.deleteWhenSwipe(index)
        
        #expect(sut.state == .error("Silinemedi"))
        
    }
    
}
