//
//  SwiftDataNoteRepository.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 1.07.2026.
//

import Foundation
import SwiftData

protocol NoteRepository {
    func fetchAll() throws -> [Note]
    func search(matching query: String) throws -> [Note]
    func add(_ note: Note) throws
    func update(_ note: Note) throws
    func delete(_ note: Note) throws
    func filter(chip: String) -> [Note]
    func save() throws
    
}

final class NoteRepositoryLive: NoteRepository {
    private let modelContext: ModelContext
    private var descriptor = FetchDescriptor<Note>(
        sortBy: [SortDescriptor(\.lastEdit)]
    )

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [Note] {
        return try modelContext.fetch(descriptor)
    }

    func search(matching query: String) throws -> [Note] {
        descriptor = FetchDescriptor<Note>(
            predicate: #Predicate { $0.title.localizedStandardContains(query) }
        )
        return try modelContext.fetch(descriptor)
    }

    func add(_ note: Note) throws {
        modelContext.insert(note)
        try save()
    }

    func update(_ note: Note) throws {
        try save()
    }

    func delete(_ note: Note) throws {
        modelContext.delete(note)
        try save()
    }
    func filter(chip: String) -> [Note] {
        descriptor = FetchDescriptor<Note>(
            predicate: #Predicate { $0.category?.name == chip }
        )
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("gene patladı \(error)")
        }
        return []
    }

    func save() throws {
        try modelContext.save()
    }
}
