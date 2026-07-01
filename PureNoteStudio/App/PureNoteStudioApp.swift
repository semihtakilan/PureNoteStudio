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
    
    private let dependencies = AppDependencies()
    @State private var tabRouter = TabRouter()
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(dependencies)
                .environment(tabRouter)
                .modelContainer(dependencies.modelContainer)
        }
    }
}
