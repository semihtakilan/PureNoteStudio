//
//  RootTabView+Ext.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 28.07.2026.
//

import SwiftUI


extension RootTabView {
    
    var mainTabView: some View {
        TabView(selection: Binding (
            get: { router.selectedTab },
            set: { router.selectedTab = $0 }
        )) {
            NotesTabView(
                appDependencies: appDependencies,
                viewModel: notesViewModel
            )
                .tabItem {
                    Label("Notes", systemImage: "text.page")
                }
                .tag(Tab.notes)
            
            NavigationStack {
                SettingsView(viewModel: settingsViewModel)
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(Tab.settings)
        }
    }
    
    var lockedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("PureNoteStudio is Locked")
                .font(.title2)
                .bold()
            
            Text("Use Face ID to view your notes.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: { viewModel.authenticate() }) {
                Text("Unlock")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appPageBackground)
    }
}
