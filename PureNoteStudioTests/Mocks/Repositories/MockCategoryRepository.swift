//
//  MockCategoryRepository.swift
//  PureNoteStudioTests
//
//  Created by Semih TAKILAN on 28.07.2026.
//

import Foundation
@testable import PureNoteStudio

final class MockCategoryRepository: CategoryRepository {
    
    var mockCategories: [PureNoteStudio.Category] = []
    
    var shouldThrowError: Bool = false
    var mockError = NSError(domain: "TestError", code: 1, userInfo: nil)
    
    private(set) var fetchAllCallCount = 0
    
    private(set) var addCategoryCallCount = 0
    private(set) var addCategoryCapturedName: String?
    
    private(set) var assignNoteCallCount = 0
    private(set) var assignNoteCapturedNote: Note?
    private(set) var assignNoteCapturedCategory: PureNoteStudio.Category?
    
    private(set) var removeFromCategoryCallCount = 0
    private(set) var removeFromCategoryCapturedNote: Note?
    private(set) var removeFromCategoryCapturedCategory: PureNoteStudio.Category?
    
    private(set) var deleteCallCount = 0
    private(set) var deleteCapturedCategory: PureNoteStudio.Category?
    
    private(set) var saveCallCount = 0
    
    func fetchAll() throws -> [PureNoteStudio.Category] {
        fetchAllCallCount += 1
        if shouldThrowError { throw mockError }
        return mockCategories
    }
    
    func addCategory(_ name: String) throws {
        addCategoryCallCount += 1
        addCategoryCapturedName = name
        if shouldThrowError { throw mockError }
    }
    
    func assignNote(_ note: PureNoteStudio.Note, _ category: PureNoteStudio.Category) throws {
        assignNoteCallCount += 1
        assignNoteCapturedNote = note
        assignNoteCapturedCategory = category
        if shouldThrowError { throw mockError }
    }
    
    func removeFromCategory(_ note: PureNoteStudio.Note, _ category: PureNoteStudio.Category) throws {
        removeFromCategoryCallCount += 1
        removeFromCategoryCapturedNote = note
        removeFromCategoryCapturedCategory = category
        if shouldThrowError { throw mockError }
    }
    
    func delete(_ category: PureNoteStudio.Category) throws {
        deleteCallCount += 1
        deleteCapturedCategory = category
        if shouldThrowError { throw mockError }
    }
    
    func save() throws {
        saveCallCount += 1
        if shouldThrowError { throw mockError }
    }
    
}
