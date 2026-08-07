//
//  NoteDetailViewModel.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 9.07.2026.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
@Observable
final class NoteDetailViewModel {
    private let noteRepository: NoteRepository
    private let notificationSchedulerLive: NotificationSchedulerLive
    private let richTextService: RichTextService
    private(set) var note: Note
    
    var attributedText: NSAttributedString = NSAttributedString()
    var isProcessing: Bool = true
    var resetStyleTrigger: Bool = false
    var selectedRange: NSRange = NSRange(location: 0, length: 0)
    var isFocused: Bool = false
    var isCameraPresented: Bool = false
    var formatState = RichTextFormatState()
    var title: String
    
    private var originalContentText: String = ""
    private var originalTitle: String
    
    var isReminderAlertPresented: Bool = false
    var selectedReminderDate: Date = Date()
    var errorMessage: String?
    private var isDeleted = false
    
    init(
        note: Note,
        noteRepository: NoteRepository,
        notificationSchedulerLive: NotificationSchedulerLive,
        richTextService: RichTextService
    ) {
        self.note = note
        self.noteRepository = noteRepository
        self.notificationSchedulerLive = notificationSchedulerLive
        self.richTextService = richTextService
        self.title = note.title
        self.originalTitle = note.title
        
        setAttributedText()
        if let existingDate = note.reminderDate {
            self.selectedReminderDate = existingDate
        }
    }
    
    func saveReminder() {
        Task {
            let granted = await notificationSchedulerLive.requestAuthorization()
            guard granted else {
                errorMessage = "Hatırlatıcı için bildirim izni gerekli."
                return
            }
            
            if let oldID = note.notificationID {
                notificationSchedulerLive.removeNotification(with: oldID)
            }
            
            do {
                let newID = try await notificationSchedulerLive.scheduleNotification(
                    title: title,
                    body: note.contentText.trimmingCharacters(in: .whitespaces),
                    date: selectedReminderDate
                )
                note.title = title
                note.reminderDate = selectedReminderDate
                note.notificationID = newID
                try noteRepository.update(note)
                originalTitle = title
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func setAttributedText() {
        if let data = note.contentData,
           let loaded = NSAttributedString.from(data: data) {
            self.attributedText = loaded
        } else {
            self.attributedText = NSAttributedString(string: note.contentText)
        }
        self.originalContentText = note.contentText
    }
    
    func onDisappear() {
        guard !isDeleted else { return }
        let newContentData = attributedText.toData()
        let newContentText = attributedText.string
        
        guard title != originalTitle || newContentText != originalContentText else {
            return
        }
        
        note.title = title
        note.contentText = newContentText
        note.contentData = newContentData
        note.lastEdit = Date()
        
        do {
            try noteRepository.update(note)
            originalTitle = title
            originalContentText = newContentText
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func delete() -> Bool {
        do {
            try noteRepository.delete(note)
            isDeleted = true
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func resizeAttachmentsIfNeeded(maxWidth: CGFloat) async {
        isProcessing = true
        attributedText = await richTextService.resizeAttachments(in: attributedText, maxWidth: maxWidth)
        isProcessing = false
    }
    
    func insertImage(_ image: UIImage, editorWidth: CGFloat) async {
        guard editorWidth > 0, image.size.width > 0, image.size.height > 0 else { return }
        
        let result = await richTextService.insertImage(
            image,
            into: attributedText,
            at: selectedRange,
            maxWidth: editorWidth
        )
        
        attributedText = result.0
        selectedRange = result.1
        
        resetStyleTrigger = true
    }
}
