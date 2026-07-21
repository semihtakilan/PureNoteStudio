//
//  Router.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 1.07.2026.
//

import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(AppDependencies.self)
    private var appDependencies
    
    @Environment(TabRouter.self)
    private var router

    var body: some View {
        TabView(selection: Binding (
            get: { router.selectedTab },
            set: { router.selectedTab = $0 }
        )) {
            NavigationStack(path: Bindable(router.notesRouter).path) {
                NotesView(
                    noteRepository: appDependencies.noteRepository,
                    categoryRepository: appDependencies.categoryRepository
                )
            }
            .environment(router.notesRouter)
            .tabItem {
                Label("Notes", systemImage: "text.page")
            }
            .tag(Tab.notes)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(Tab.settings)
        }
        .modelContainer(appDependencies.modelContainer)
    }
}
