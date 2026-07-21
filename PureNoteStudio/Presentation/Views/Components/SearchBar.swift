//
//  SearchBarView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 29.06.2026.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search", text: $searchText)
        }
        .padding(10)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
