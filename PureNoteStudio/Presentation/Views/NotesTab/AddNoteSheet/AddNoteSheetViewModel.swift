//
//  AddNoteSheetViewModel.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 6.07.2026.
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
@Observable
final class AddNoteSheetViewModel {
    private let noteRepository: NoteRepository
    private let richTextService: RichTextServiceProtocol
    
    var title: String = ""
    var attributedText = NSAttributedString(string: "")
    var selectedPhoto: PhotosPickerItem?
    var shouldResetEditorStyle: Bool = false
    var selectedRange: NSRange = NSRange(location: 0, length: 0)
    
    init(
        noteRepository: NoteRepository,
        richTextService: RichTextServiceProtocol
    ) {
        self.noteRepository = noteRepository
        self.richTextService = richTextService
    }
    
    func saveNote() throws {
        let contentText = attributedText.string
        let contentData = attributedText.toData()
        let note = Note(title: title, contentText: contentText, contentData: contentData)
        try noteRepository.add(note)
    }

    func insertImage(_ image: UIImage, editorWidth: CGFloat) async {
        guard editorWidth > 0,
              image.size.width > 0,
              image.size.height > 0 else {
            print("Geçersiz boyut — editorWidth: \(editorWidth), image: \(image.size)")
            return
        }

        let result = await richTextService.insertImage(
            image,
            into: attributedText,
            at: selectedRange,
            maxWidth: editorWidth
        )
        
        attributedText = result.0
        selectedRange = result.1
        
        selectedPhoto = nil
        shouldResetEditorStyle = true
    }
}
