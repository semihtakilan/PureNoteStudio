import Foundation
import UIKit

@Observable
final class AddNoteSheetViewModel {
    var title: String = ""
    var attributedText = NSAttributedString(string: "")

    
    func insertImage(_ image: UIImage, editorWidth: CGFloat) async {
        guard editorWidth > 0,
              image.size.width > 0,
              image.size.height > 0 else {
            print("Geçersiz boyut — editorWidth: \(editorWidth), image: \(image.size)")
            return
        }
        let maxWidth = editorWidth
        let resized = await resizeImage(image, maxWidth: maxWidth)
        
        let attachment = NSTextAttachment()
        attachment.image = resized
        attachment.bounds = CGRect(x: 0, y: 0, width: maxWidth, height: resized.size.height)
        
        let mutableAttr = NSMutableAttributedString(attributedString: attributedText)
        mutableAttr.append(NSAttributedString(string: "\n"))
        mutableAttr.append(NSAttributedString(attachment: attachment))
        mutableAttr.append(NSAttributedString(string: "\n"))
        attributedText = mutableAttr
    }
    
    func resizeImage(_ image: UIImage, maxWidth: CGFloat) async -> UIImage {
        let ratio = image.size.height / image.size.width
        let targetSize = CGSize(width: maxWidth, height: maxWidth * ratio)
        
        guard targetSize.width > 0, targetSize.height > 0,
              !targetSize.width.isNaN, !targetSize.height.isNaN else {
            print("Geçersiz targetSize, orijinal image döndürülüyor")
            return image
        }
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: targetSize)) }
    }
}
