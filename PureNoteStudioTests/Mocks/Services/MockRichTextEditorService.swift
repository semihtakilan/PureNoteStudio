//
//  MockRichTextEditorService.swift
//  PureNoteStudioTests
//
//  Created by Semih TAKILAN on 28.07.2026.
//

import UIKit
@testable import PureNoteStudio

@MainActor
final class MockRichTextService: RichTextServiceProtocol {
    
    var mockResizedAttributedString = NSAttributedString()
    
    var mockInsertedAttributedString = NSAttributedString()
    var mockInsertedRange = NSRange()
    
    private(set) var resizedCallCount = 0
    private(set) var resizedCapturedAttributedString: NSAttributedString?
    private(set) var resizedCapturedMaxWidth: CGFloat?
    
    private(set) var insertedCallCount = 0
    private(set) var insertedCapturedText: NSAttributedString?
    private(set) var insertedCapturedRange: NSRange?
    private(set) var insertedCapturedMaxWidth: CGFloat?
    
    func resizeAttachments(
        in attributedString: NSAttributedString,
        maxWidth: CGFloat
    ) async -> NSAttributedString {
        resizedCallCount += 1
        resizedCapturedAttributedString = attributedString
        resizedCapturedMaxWidth = maxWidth
        return mockResizedAttributedString
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
        insertedCallCount += 1
        insertedCapturedText = text
        insertedCapturedRange = range
        insertedCapturedMaxWidth = maxWidth
        
        return (mockInsertedAttributedString, mockInsertedRange)
    }
    
    
}
