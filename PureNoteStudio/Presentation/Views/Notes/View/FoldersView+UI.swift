//
//  FoldersView+UI.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 20.07.2026.
//

import SwiftUI

extension FoldersView {
    func FolderRow(item: CategoryFilter, customCount: Int? = nil) -> some View {
        Button {
            router.pop()
        } label: {
            HStack {
                Image(systemName: "folder.fill")
                
                Text(item.name)
                    .font(.headline)
                
                Spacer()
                
                let count = customCount ?? {
                    if case .folder(let category) = item {
                        return category.notes.count
                    }
                    return 0
                }()
                
                Text(count.description)
            }
        }
        .foregroundColor(.primary)
        
    }
}
