//
//  CategoryRow.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 14.07.2026.
//

import SwiftUI

struct CategoryRow: View {
    @Environment(FoldersRouter.self)
    private var route
    
    let category: Category
    
    var body: some View {
        Button {
            route.push(.detail(category))
        } label: {
            HStack {
                Image(systemName: "folder")
                
                Text(category.name)
                    .font(.headline)
                
                Spacer()
                
                Text(category.notes.count.description)
                
                Image(systemName: "chevron.right")
            }
        }
    }
}
