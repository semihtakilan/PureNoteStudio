//
//  FolderDetailView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 14.07.2026.
//

import SwiftUI

struct FolderDetailView: View {
    let category: Category
    
    var body: some View {
        Text(category.name)
    }
}
