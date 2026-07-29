//
//  MockNoteRepository.swift
//  PureNoteStudioTests
//
//  Created by Semih TAKILAN on 28.07.2026.
//

import Foundation
@testable import PureNoteStudio

final class MockNoteRepository: NoteRepository {
    
    var mockAllNotes: [Note] = []
    var mockSearchedNotes: [Note] = []
    var mockFilteredNotes: [Note] = []
    
    var shouldThrowError: Bool = false
    var mockError = NSError(domain: "TestError", code: 1, userInfo: nil)
    
    private(set) var fetchAllCallCount = 0
    
    private(set) var searchCallCount = 0
    private(set) var searchCapturedQuery: String?
    
    private(set) var addCallCount = 0
    private(set) var addCapturedNote: Note?
    
    private(set) var updateCallCount = 0
    private(set) var updateCaptureNote: Note?
    
    private(set) var deleteCallCount = 0
    private(set) var deleteCapturedNote: Note?
    
    private(set) var filterCallCount = 0
    private(set) var filterCapturedFilter: String?
    
    private(set) var saveCallCount = 0
    
    func fetchAll() throws -> [PureNoteStudio.Note] {
        fetchAllCallCount += 1
        if shouldThrowError { throw mockError }
        return mockAllNotes
    }
    
    func search(matching query: String) throws -> [PureNoteStudio.Note] {
        searchCallCount += 1
        searchCapturedQuery = query
        if shouldThrowError { throw mockError }
        return mockSearchedNotes
    }
    
    func add(_ note: PureNoteStudio.Note) throws {
        addCallCount += 1
        addCapturedNote = note
        if shouldThrowError { throw mockError }
    }
    
    func update(_ note: PureNoteStudio.Note) throws {
        updateCallCount += 1
        updateCaptureNote = note
        if shouldThrowError { throw mockError }
    }
    
    func delete(_ note: PureNoteStudio.Note) throws {
        deleteCallCount += 1
        deleteCapturedNote = note
        if shouldThrowError { throw mockError }
    }
    
    func filter(_ filter: String) -> [PureNoteStudio.Note] {
        filterCallCount += 1
        filterCapturedFilter = filter
        return mockFilteredNotes
    }
    
    func save() throws {
        saveCallCount += 1
        if shouldThrowError { throw mockError }
    }
    
    
}
