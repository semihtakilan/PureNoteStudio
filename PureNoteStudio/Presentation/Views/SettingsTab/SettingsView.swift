//
//  SettingsView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 29.06.2026.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @AppStorage("appFontSize") private var appFontSize: AppFontSize = .medium
    @AppStorage("selectedLayout") private var selectedLayout: String = "List View"
    
    @Bindable var viewModel: SettingsViewModel
    
    let layouts: [String] = ["List View", "Grid View"]
    
    var body: some View {
        
        Form {
            Section("Claude Services") {
                Text("Not configured yet...")
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
        .background(Color.appPageBackground)
        .navigationTitle("Settings")
        .alert("Doğrulama Hatası", isPresented: $viewModel.showAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage)
        }
        
    }
}
