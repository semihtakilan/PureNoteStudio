//
//  NoteRepositoryLiveTests.swift
//  PureNoteStudio
//
//  Created by Batuhan Baran on 24.07.2026.
//

@testable
import PureNoteStudio
import SwiftData
import Testing
import Foundation

struct NoteRepositoryLiveTests {
    let sut: NoteRepositoryLive
    let modelContext: ModelContext

    init() throws {
        let schema = Schema([Note.self, Category.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        self.modelContext = ModelContext(container)
        self.sut = NoteRepositoryLive(modelContext: modelContext)
    }

    @Test
    func testFetchAllReturnsSortedByLastEdit() throws {
        let older = Note(title: "Old", contentText: "", lastEdit: Date.now.addingTimeInterval(-1000))
        let newer = Note(title: "New", contentText: "", lastEdit: Date.now)
        try sut.add(older)
        try sut.add(newer)

        let result = try sut.fetchAll()

        #expect(result.map(\.title) == ["New", "Old"])
    }

    @Test
    func testSearchMatchesTitleOrContent() throws {
        let match = Note(title: "Swift Notes", contentText: "irrelevant")
        let noMatch = Note(title: "Other", contentText: "nothing here")
        try sut.add(match)
        try sut.add(noMatch)

        let result = try sut.search(matching: "swift")

        #expect(result.count == 1)
        #expect(result.first?.title == "Swift Notes")
    }
}
