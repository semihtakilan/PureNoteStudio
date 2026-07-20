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

    init() {
        configureNavigationBarAppearance()
        configureTabBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(dependencies)
                .environment(tabRouter)
                .modelContainer(dependencies.modelContainer)
        }
    }

    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
