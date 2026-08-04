//
//  SettingsView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 29.06.2026.
//

import SwiftUI

struct SettingsView: View {
    let appDependencies: AppDependencies
    
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @AppStorage("appFontSize") private var appFontSize: AppFontSize = .medium
    
    @State private var viewModel: SettingsViewModel
    
    let layouts: [String] = ["List View", "Grid View"]
    
    @State private var selectedLayout: String = "List View"
    
    init(appDependencies: AppDependencies) {
        self.appDependencies = appDependencies
        self._viewModel = State(initialValue: SettingsViewModel(authService: appDependencies.authService))
    }
    
    var body: some View {
        VStack {
            Form {
                Section("Claude Services") {
                    Text("Henüz eklenmedi...")
                }
                
                Section("Style") {
                    Picker("Font size", selection: $appFontSize) {
                        ForEach(AppFontSize.allCases, id:\.self) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                    Picker("Layout", selection: $selectedLayout) {
                        ForEach(layouts, id:\.self) { layout in
                            Text(layout).tag(layout)
                        }
                    }
                }
                
                Section("Display Mode") {
                    Picker("Display Mode", selection: $appTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                }
                
                Section("FaceID") {
                    Toggle("FaceID", isOn: Binding(
                        get: { viewModel.isFaceIDEnabled },
                        set: { newValue in viewModel.toggleFaceID(isOn: newValue) }
                    ))
                }
                
                Section("About the App") {
                    LabeledContent("App Version", value: "1.0")
                }
            }
            .scrollContentBackground(.hidden)
        }
        .background(Color(.systemGray6))
        .navigationTitle("Settings")
        .alert("Doğrulama Hatası", isPresented: $viewModel.showAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}
