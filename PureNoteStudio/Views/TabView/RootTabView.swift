//
//  Router.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 1.07.2026.
//

import SwiftUI

struct RootTabView: View {
    @State private var router = TabRouter()
    
    var body: some View {
        TabView(selection: Binding (
            get: { router.selectedTab },
            set: { router.selectedTab = $0 }
        )) {
            
            NavigationStack(path: Bindable(router.notesRouter).path) {
                NotesView()
                    .navigationDestination(for: NotesRoute.self) { route in
                        switch route {
                        case .detail(let id):
                            NoteDetailView(noteID: id)
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
    }
}
