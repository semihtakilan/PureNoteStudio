//
//  RichTextService.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 22.07.2026.
//

import UIKit

@MainActor
protocol RichTextService {
    func resizeAttachments(
        in attributedString: NSAttributedString,
        maxWidth: CGFloat
    ) async -> NSAttributedString
    
    func insertImage(
        _ image: UIImage,
        into text: NSAttributedString,
        at range: NSRange,
        maxWidth: CGFloat
    ) async -> (
        NSAttributedString,
        NSRange
    )
}
