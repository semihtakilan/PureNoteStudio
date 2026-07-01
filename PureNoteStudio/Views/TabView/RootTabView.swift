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
                NotesView(repository: appDependencies.noteRepository)
                    .navigationDestination(for: NotesRoute.self) { route in
                        switch route {
                        case .detail(let note):
                            NoteDetailView(note: note)
                        }
                    }
            }
            .environment(router.notesRouter)
            .tabItem {
                Label("Notes", systemImage: "text.page")
            }
            .tag(Tab.notes)
            
            NavigationStack {
                FoldersView()
            }
            .tabItem {
                Label("Folders", systemImage: "folder")
            }
            .tag(Tab.folders)
            
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
