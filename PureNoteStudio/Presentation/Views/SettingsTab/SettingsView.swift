//
//  SettingsView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 29.06.2026.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    
    // MockDatas
    let fontSizes = ["Small", "Medium", "Large", "Huge"]
    let layouts: [String] = ["List View", "Grid View"]
    
    // MockVars
    @State private var selectedFontSize: String = "Medium"
    @State private var selectedLayout: String = "List View"
    
    var body: some View {
        VStack {
            Form {
                Section("Claude Services") {
                    Text("Henüz eklenmedi...")
                }
                
                Section("Style") {
                    Picker("Font size", selection: $selectedFontSize) {
                        ForEach(fontSizes, id:\.self) { fontSize in
                            Text(fontSize).tag(fontSize)
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
                
                Section("About the App") {
                    LabeledContent("App Version", value: "1.0")
                }
            }
        }
        .navigationTitle("Settings")
        .background(Color(.systemGray6))
    }
}
