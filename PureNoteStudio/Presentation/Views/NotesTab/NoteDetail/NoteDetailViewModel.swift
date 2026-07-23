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
    private let categoryRepository: CategoryRepository
    private let notificationManager: NotificationManager
    private let richTextService: RichTextServiceProtocol
    private(set) var note: Note
    
    var attributedText: NSAttributedString = NSAttributedString()
    var isProcessing: Bool = true
    var resetStyleTrigger: Bool = false
    var selectedRange: NSRange = NSRange(location: 0, length: 0)
    var isFocused: Bool = false
    
    private var originalContentText: String = ""
    
    var title: String { note.title }
    
    var isReminderAlertPresented: Bool = false
    var selectedReminderDate: Date = Date()
    
    init(
        note: Note,
        noteRepository: NoteRepository,
        categoryRepository: CategoryRepository,
        notificationManager: NotificationManager,
        richTextService: RichTextServiceProtocol
    ) {
        self.note = note
        self.noteRepository = noteRepository
        self.categoryRepository = categoryRepository
        self.notificationManager = notificationManager
        self.richTextService = richTextService
        
        setAttributedText()
        if let existingDate = note.reminderDate {
            self.selectedReminderDate = existingDate
        }
    }
    
    func saveReminder() {
        Task {
            let granted = await notificationManager.requestAuthorization()
            guard granted else {
                print("Kullanıcı bildirim iznini reddetti.")
                return
            }
            
            if let oldID = note.notificationID {
                notificationManager.removeNotification(with: oldID)
            }
            
            if let newID = notificationManager.scheduleNotification(
                title: note.title,
                body: note.contentText.trimmingCharacters(in: .whitespaces),
                date: selectedReminderDate
            ) {
                note.reminderDate = selectedReminderDate
                note.notificationID = newID
                
                do {
                    try noteRepository.update(note)
                } catch {
                    print("Not kaydedilemedi: \(error)")
                }
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
        let newContentData = attributedText.toData()
        let newContentText = attributedText.string
        
        guard newContentText != originalContentText else {
            return
        }
        
        note.contentText = newContentText
        note.contentData = newContentData
        note.lastEdit = Date()
        
        do {
            try noteRepository.update(note)
        } catch {
            print("Not güncellenemedi \(error)")
        }
    }
    
    func delete() {
        do {
            try noteRepository.delete(note)
        } catch {
            print("Note delete error \(error)")
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
