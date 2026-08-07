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
            .listRowBackground(Color.appControlBackground)
            
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
            .listRowBackground(Color.appControlBackground)
            
            Section("Display Mode") {
                Picker("Display Mode", selection: $appTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
            }
            .listRowBackground(Color.appControlBackground)
                               
            Section("FaceID") {
                Toggle("FaceID", isOn: Binding(
                    get: { viewModel.isFaceIDEnabled },
                    set: { newValue in viewModel.toggleFaceID(isOn: newValue) }
                ))
            }
            .listRowBackground(Color.appControlBackground)
            
            Section("About the App") {
                LabeledContent("App Version", value: "1.0")
            }
            .listRowBackground(Color.appControlBackground)
        }
        .scrollContentBackground(.hidden)
        .background(Color(.systemGray6))
        .navigationTitle("Settings")
        .alert("Doğrulama Hatası", isPresented: $viewModel.showAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage)
        }
        
    }
}
