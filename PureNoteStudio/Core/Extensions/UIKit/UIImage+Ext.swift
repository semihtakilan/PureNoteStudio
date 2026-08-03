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
            guard self.size.width > 0, self.size.height > 0, maxWidth > 0 else {
                return self
            }

            let targetWidth = min(self.size.width, maxWidth)
            let ratio = self.size.height / self.size.width
            let targetSize = CGSize(width: targetWidth, height: targetWidth * ratio)
            
            guard targetSize.width > 0, targetSize.height > 0,
                  !targetSize.width.isNaN, !targetSize.height.isNaN else {
                return self
            }
            
            guard targetSize != self.size else { return self }

            let format = UIGraphicsImageRendererFormat.default()
            format.scale = self.scale
            let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
            return renderer.image { context in
                context.cgContext.interpolationQuality = .high
                context.cgContext.setShouldAntialias(true)
                
                self.draw(in: CGRect(origin: .zero, size: targetSize))
            }
        }.value
    }
}
