//
//  ContentView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 26.06.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext)
    private var modelContext
    
    @State var searchText = ""
    @State var selectedCategory: String = "All"
    let categories: [String] = ["All", "Healt", "Shopping"]
    
    @Query var notes: [Note]
    
    var body: some View {
        
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Notes")
                    .font(.largeTitle.bold())
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                searchBar
                
                categoriesView
                
                
                noteListView
                
            }
            .background(Color.white)
            .background(Color(.systemGray6).ignoresSafeArea())
            .toolbar {
                Button("Add", systemImage: "plus", action: addSamples)
            }
        }
    }
    
    func addSamples() {
        let sample1 = Note(title: "Note1", contentText: "Content1")
        let sample2 = Note(title: "Note2", contentText: "Content2")
        let sample3 = Note(title: "Note3", contentText: "Content3")
        
        modelContext.insert(sample1)
        modelContext.insert(sample2)
        modelContext.insert(sample3)
    }
    
    
    func setCategory(title: String) {
        selectedCategory = title
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Ara", text: $searchText)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    private var noteListView: some View {
        NavigationLink(destination: Text("Detail")) {
            List {
                ForEach(notes) { note in
                    VStack(alignment: .leading) {
                        Text(note.title)
                            .font(.headline)
                        
                        Text(note.contentText)
                    }
                }
            }
        }
    }
    
    private var categoriesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    FilterPillButton(
                        title: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                    }
                }
            }

        }
    }
    
}

#Preview {
    ContentView()
}

struct FilterPillButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                )
        }
        .buttonStyle(.plain)
    }
}
