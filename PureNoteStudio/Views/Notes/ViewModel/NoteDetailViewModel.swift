//
//  NoteDetailViewModel.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 9.07.2026.
//


import Foundation
import SwiftUI
import UIKit

@Observable
final class NoteDetailViewModel {
    private let noteRepository: NoteRepository
    private let note: Note
    
    var attributedText: NSAttributedString = NSAttributedString()
    var isProcessing: Bool = true
    var resetStyleTrigger: Bool = false
    var selectedRange: NSRange = NSRange(location: 0, length: 0)
    
    private var originalContentText: String = ""
    
    var title: String { note.title }
    
    init(note: Note, noteRepository: NoteRepository) {
        self.note = note
        self.noteRepository = noteRepository
        setAttributedText()
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
    
    func resizeAttachmentsIfNeeded(maxWidth: CGFloat) async {
        isProcessing = true
        attributedText = await resizeAttachments(in: attributedText, maxWidth: maxWidth)
        isProcessing = false
    }
    
    private func resizeAttachments(in attributedString: NSAttributedString, maxWidth: CGFloat) async -> NSAttributedString {
        let mutableAttr = NSMutableAttributedString(attributedString: attributedString)
        let fullRange = NSRange(location: 0, length: mutableAttr.length)
        
        var attachmentsToReplace: [(NSRange, UIImage)] = []
        
        mutableAttr.enumerateAttribute(.attachment, in: fullRange, options: []) { value, range, _ in
            guard let attachment = value as? NSTextAttachment else { return }
            
            if let image = attachment.image ?? (attachment.fileWrapper?.regularFileContents.flatMap { UIImage(data: $0) }) {
                attachmentsToReplace.append((range, image))
            }
        }
        
        for (range, image) in attachmentsToReplace.reversed() {
            let adjustedWidth = maxWidth - 10
            
            let resizedImage = await image.resized(toMaxWidth: adjustedWidth)
            
            let newAttachment = NSTextAttachment()
            newAttachment.image = resizedImage
            newAttachment.bounds = CGRect(x: 0, y: 0, width: resizedImage.size.width, height: resizedImage.size.height)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attachmentString = NSMutableAttributedString(attachment: newAttachment)
            let fullAttachmentRange = NSRange(location: 0, length: attachmentString.length)
            attachmentString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullAttachmentRange)
            
            mutableAttr.replaceCharacters(in: range, with: attachmentString)
        }
        
        return mutableAttr
    }
}

extension UIImage {
    func resized(toMaxWidth maxWidth: CGFloat) async -> UIImage {
        await Task.detached(priority: .userInitiated) {
            let ratio = self.size.height / self.size.width
            let targetSize = CGSize(width: maxWidth, height: maxWidth * ratio)
            
            guard targetSize.width > 0, targetSize.height > 0,
                  !targetSize.width.isNaN, !targetSize.height.isNaN else {
                return self
            }
            
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            return renderer.image { context in
                context.cgContext.interpolationQuality = .high
                context.cgContext.setShouldAntialias(true)
                
                self.draw(in: CGRect(origin: .zero, size: targetSize))
            }
        }.value
    }
}
