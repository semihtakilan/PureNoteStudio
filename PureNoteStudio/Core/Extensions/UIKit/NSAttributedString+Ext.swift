//
//  NSAttributedString+Ext.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 20.07.2026.
//

import UIKit

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
