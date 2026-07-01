//
//  Category.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 29.06.2026.
//

import Foundation
import SwiftData

@Model
final class Category {
    var id: UUID = UUID()
    var name: String
    var isSelected: Bool = false
    private(set) var createdOn: Date = Date()
    
    @Relationship(deleteRule: .nullify, inverse: \Note.category)
    var notes: [Note] = []
    
    init(name: String) {
        self.name = name
    }
}
