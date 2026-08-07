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
    private let richTextService: RichTextService
    
    var title: String = ""
    var attributedText = NSAttributedString(string: "")
    var selectedPhoto: PhotosPickerItem?
    var shouldResetEditorStyle: Bool = false
    var selectedRange: NSRange = NSRange(location: 0, length: 0)
    var isFocused: Bool = false
    var isCameraPresented: Bool = false
    var formatState = RichTextFormatState()
    var errorMessage: String?
    
    init(
        noteRepository: NoteRepository,
        richTextService: RichTextService
    ) {
        self.noteRepository = noteRepository
        self.richTextService = richTextService
    }
    
    func saveNote() -> Bool {
        let contentText = attributedText.string
        let contentData = attributedText.toData()
        let note = Note(title: title, contentText: contentText, contentData: contentData)
        do {
            try noteRepository.add(note)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
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
        
        shouldResetEditorStyle = true
    }
}
