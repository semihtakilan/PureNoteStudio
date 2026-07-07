//
//  AddNoteSheet.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 6.07.2026.
//

import SwiftUI

struct AddNoteSheet: View {
    let onSave: (String, String) throws -> Void
    @Environment(NotesRouter.self)
    private var router
    
    @State private var title: String = ""
    @State private var content: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: - TopButtonSection
            HStack {
                Button("Cancel") {
                    router.dissmissSheet()
                }
                
                Spacer()
                
                Button("Save") {
                    try? onSave(title, content)
                    router.dissmissSheet()
                }
                .disabled(title.isEmpty)
            }
            .padding(.top, 16)
            
            Divider()
                .ignoresSafeArea()
            
            // MARK: - DateSection
            Text(Date.now.formatted(
                .dateTime
                    .day(.defaultDigits)
                    .month(.wide)
                    .year(.defaultDigits)
                    .hour(.twoDigits(amPM: .abbreviated))
                    .minute(.twoDigits)
                    .locale(Locale(identifier: "en_US"))
                )
            )
                .font(.subheadline)
                .opacity(0.5)
                .frame(minWidth: 0, maxWidth: .infinity ,alignment: .center)
            
            // MARK: - TitleSection
            TextField("New Title", text: $title)
                .font(.largeTitle)
                .bold()
            
            // MARK: - ContentSection
            ZStack {
                if content.isEmpty {
                    Text("Start typing your note...")
                        .font(.custom("Helvetica", size: 24))
                }
                
                TextEditor(text: $content)
                    .font(.custom("Helvetica", size: 24))
            }
        }
        .padding()
    }
}
