import Foundation
import SwiftUI
import PhotosUI

@Observable
final class AddNoteSheetViewModel {
    var title: String = ""
    var attributedText = NSAttributedString(string: "")
    var selectedPhoto: PhotosPickerItem?
    var shouldResetEditorStyle: Bool = false

    func insertImage(_ image: UIImage, editorWidth: CGFloat) async {
        guard editorWidth > 0,
              image.size.width > 0,
              image.size.height > 0 else {
            print("Geçersiz boyut — editorWidth: \(editorWidth), image: \(image.size)")
            return
        }
        
        let resized = await image.resized(toMaxWidth: editorWidth)
        
        let attachment = NSTextAttachment()
        attachment.image = resized
        attachment.bounds = CGRect(x: 0, y: 0, width: editorWidth, height: resized.size.height)
        
        let mutableAttr = NSMutableAttributedString(attributedString: attributedText)
        mutableAttr.append(NSAttributedString(string: "\n"))
        mutableAttr.append(NSAttributedString(attachment: attachment))
        mutableAttr.append(NSAttributedString(string: "\n"))
        attributedText = mutableAttr
        selectedPhoto = nil
        shouldResetEditorStyle = true
    }

}

extension NSAttributedString {
    func toData() -> Data? {
        try? self.data(
            from: NSRange(location: 0, length: self.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd]
        )
    }
    
    static func from(data: Data) -> NSAttributedString? {
        try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.rtfd],
            documentAttributes: nil
        )
    }
}

