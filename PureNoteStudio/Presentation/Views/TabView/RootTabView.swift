//
//  Router.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 1.07.2026.
//

import SwiftUI
import SwiftData

struct RootTabView: View {
    let appDependencies: AppDependencies
    
    @Environment(TabRouter.self)
    var router
    
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @AppStorage("appFontSize") private var appFontSize: AppFontSize = .medium
    
    @State private(set) var viewModel: RootTabViewModel
    @State var notesViewModel: NotesViewModel
    @State var settingsViewModel: SettingsViewModel
    
    init(appDependencies: AppDependencies) {
        self.appDependencies = appDependencies
        self._viewModel = State(initialValue: RootTabViewModel(authService: appDependencies.authService))
        self._notesViewModel = State(
            initialValue: NotesViewModel(
                noteRepository: appDependencies.noteRepository,
                categoryRepository: appDependencies.categoryRepository
            )
        )
        self._settingsViewModel = State(
            initialValue: SettingsViewModel(authService: appDependencies.authService)
        )
    }
    
    var body: some View {
        Group {
            if viewModel.isUnlocked {
                mainTabView
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                lockedView
                    .transition(.opacity)
            }
        }
        .onAppear(perform: viewModel.authenticate)
        .environment(\.sizeCategory, appFontSize.dynamicType)
        .preferredColorScheme(appTheme.colorScheme)
        .tint(.accentColor)
    }
}
