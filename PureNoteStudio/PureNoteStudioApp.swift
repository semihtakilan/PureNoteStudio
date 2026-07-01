//
//  PureNoteStudioApp.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 26.06.2026.
//

import SwiftUI
import SwiftData

@main
struct PureNoteStudioApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Note.self,
            Category.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Uygulama patladı: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
