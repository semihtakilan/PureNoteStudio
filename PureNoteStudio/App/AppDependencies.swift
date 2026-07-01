//
//  AppDependencies.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 1.07.2026.
//

import SwiftUI
import SwiftData

@Observable
final class AppDependencies {
    let modelContainer: ModelContainer
    let modelContext: ModelContext
    
    let noteRepository: NoteRepository
    let categoryRepository: CategoryRepository

    init() {
        let schema = Schema([Note.self, Category.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Uygulama patladı: \(error)")
        }
        self.modelContext = ModelContext(modelContainer)
        self.noteRepository = NoteRepositoryLive(modelContext: modelContext)
        self.categoryRepository = CategoryRepositoryLive(modelContext: modelContext)
    }
}
