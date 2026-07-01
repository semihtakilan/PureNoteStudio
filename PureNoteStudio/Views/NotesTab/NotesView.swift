//
//  NotesView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 28.06.2026.
//

import SwiftUI

@Observable
class NotesViewModel {
    
}

struct NotesView: View {
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "All"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // MARK: - Title
            Text("Notes")
                .font(.largeTitle)
                .bold(true)
                .padding(.top)
                
            // MARK: - SearchBar
            SearchBarView(searchText: $searchText)
            
            // MARK: - Categories
            CategoriesView()

            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    NotesView()
}
