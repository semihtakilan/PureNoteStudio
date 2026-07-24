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
    var contentData: Data?
    var lastEdit: Date
    var category: Category?
    
    var reminderDate: Date?
    var notificationID: String?
    
    init(
        title: String,
        contentText: String,
        contentData: Data? = nil,
        category: Category? = nil,
        lastEdit: Date = Date()
    ) {
        self.title = title
        self.contentText = contentText
        self.contentData = contentData
        self.category = category
        self.lastEdit = lastEdit
    }
}
