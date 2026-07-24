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
    
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    
    var body: some View {
        TabView(selection: Binding (
            get: { router.selectedTab },
            set: { router.selectedTab = $0 }
        )) {
            
            NotesTabCoordinator(appDependencies: appDependencies)
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
        .preferredColorScheme(appTheme.colorScheme)
        .modelContainer(appDependencies.modelContainer)
    }
}
