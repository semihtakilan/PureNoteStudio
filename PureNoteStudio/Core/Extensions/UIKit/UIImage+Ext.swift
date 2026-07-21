//
//  UIImage+Ext.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 20.07.2026.
//

import UIKit

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
