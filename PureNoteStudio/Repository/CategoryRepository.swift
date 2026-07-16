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
    func addCategory(_ name: String) throws
    func assignNote(_ note: Note,_ category: Category) throws
    func removeFromCategory(_ note: Note, _ category: Category) throws
    func delete(_ category: Category) throws
    func save() throws
}

final class CategoryRepositoryLive: CategoryRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchAll() throws -> [Category] {
        let descriptor = FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func addCategory(_ name: String) throws{
        let newCategory = Category(name: name)
        modelContext.insert(newCategory)
        try save()
    }
    
    func assignNote(_ note: Note, _ category: Category) throws {
        note.category = category
        try save()
    }
    
    func removeFromCategory(_ note: Note, _ category: Category) throws {
        note.category = nil
        try save()
    }
    
    func delete(_ category: Category) throws {
        modelContext.delete(category)
        try save()
    }
    
    func save() throws {
        try modelContext.save()
    }
    
}
