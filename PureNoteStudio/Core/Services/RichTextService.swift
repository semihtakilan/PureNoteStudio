//
//  RichTextServiceProtocol.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 22.07.2026.
//

import SwiftUI
import UIKit

@MainActor
final class RichTextService: RichTextServiceProtocol {
    
    func resizeAttachments(
        in attributedString: NSAttributedString,
        maxWidth: CGFloat
    ) async -> NSAttributedString {
        let mutableAttr = NSMutableAttributedString(attributedString: attributedString)
        let fullRange = NSRange(location: 0, length: mutableAttr.length)
        
        var attachmentsToReplace: [(NSRange, UIImage)] = []
        
        mutableAttr.enumerateAttribute(.attachment, in: fullRange, options: []) {
            value,
            range,
            _ in
            guard let attachment = value as? NSTextAttachment else { return }
            
            if let image = attachment.image ?? (
                attachment.fileWrapper?.regularFileContents.flatMap {
                    UIImage(
                        data: $0
                    )
                }) {
                attachmentsToReplace.append((range, image))
            }
        }
        
        for (range, image) in attachmentsToReplace.reversed() {
            let adjustedWidth = maxWidth - 10
            let resizedImage = await image.resized(toMaxWidth: adjustedWidth)
            
            let newAttachment = NSTextAttachment()
            newAttachment.image = resizedImage
            newAttachment.bounds = CGRect(
                x: 0,
                y: 0,
                width: resizedImage.size.width,
                height: resizedImage.size.height
            )
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attachmentString = NSMutableAttributedString(attachment: newAttachment)
            let fullAttachmentRange = NSRange(location: 0, length: attachmentString.length)
            attachmentString
                .addAttribute(
                    .paragraphStyle,
                    value: paragraphStyle,
                    range: fullAttachmentRange
                )
            
            mutableAttr.replaceCharacters(in: range, with: attachmentString)
        }
        
        return mutableAttr
    }
    
    func insertImage(
        _ image: UIImage,
        into text: NSAttributedString,
        at range: NSRange,
        maxWidth: CGFloat
    ) async -> (
        NSAttributedString,
        NSRange
    ) {
        let resized = await image.resized(toMaxWidth: maxWidth)
        
        let attachment = NSTextAttachment()
        attachment.image = resized
        attachment.bounds = CGRect(
            x: 0,
            y: 0,
            width: maxWidth,
            height: resized.size.height
        )
        
        let currentFont = UIFont.preferredFont(forTextStyle: .body)
        
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: currentFont,
            .foregroundColor: UIColor.label
        ]
        
        let insertion = NSMutableAttributedString()
        insertion.append(NSAttributedString(string: "\n", attributes: baseAttributes))
        insertion.append(NSAttributedString(attachment: attachment))
        insertion.append(NSAttributedString(string: "\n", attributes: baseAttributes))
        
        let mutableAttr = NSMutableAttributedString(attributedString: text)
        let safeLocation = min(max(range.location, 0), mutableAttr.length)
        mutableAttr.insert(insertion, at: safeLocation)
        
        let newRange = NSRange(location: safeLocation + insertion.length, length: 0)
        return (mutableAttr, newRange)
    }
}
