//
//  Note.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 26.06.2026.
//

import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID = UUID()
    var title: String
    var contentText: String
    var createdOn: Date = Date()
    var category: String
    
    init(title: String, contentText: String, category: String = "") {
        self.title = title
        self.contentText = contentText
        self.category = category
    }
}
