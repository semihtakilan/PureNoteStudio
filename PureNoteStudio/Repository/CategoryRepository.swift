//
//  CategoryRepository.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 1.07.2026.
//

import Foundation
import SwiftData

protocol CategoryRepository {
    func fetchAll() throws -> [Category]
    func load() throws -> Category?
    func create(name: String) throws -> Category
    func addNote() throws
    func deleteNote(id: UUID) throws
    func deleteCategory(id: UUID) throws
}


final class CategoryRepositoryLive {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchAll() throws -> [Note] {
        let descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.lastEdit)]
        )
        return try modelContext.fetch(descriptor)
    }
    
}
