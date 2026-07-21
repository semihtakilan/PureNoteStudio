//
//  CategoryFilter.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 21.07.2026.
//


import Foundation

enum CategoryFilter: Identifiable, Hashable {
    case all
    case uncategorized
    case folder(Category)
    
    var id: String {
        switch self {
        case .all: return "all"
        case .uncategorized: return "uncategorized"
        case .folder(let category): return category.id.uuidString
        }
    }
    
    var name: String {
        switch self {
        case .all: return "All"
        case .uncategorized: return "Uncategorized"
        case .folder(let category): return category.name
        }
    }
}
