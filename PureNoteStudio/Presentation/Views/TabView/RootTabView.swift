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
    
    @State private(set) var viewModel: RootTabViewModel
    
    init(appDependencies: AppDependencies) {
        self.appDependencies = appDependencies
        self._viewModel = State(initialValue: RootTabViewModel(authService: appDependencies.authService))
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
        .preferredColorScheme(appTheme.colorScheme)
    }
}
