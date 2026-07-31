//
//  AppFontSize.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 29.07.2026.
//

import SwiftUI

enum AppFontSize: String, CaseIterable, Identifiable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var id: Self { self }
    
    var dynamicType: ContentSizeCategory {
        switch self {
        case .small: return .small
        case .medium: return .large
        case .large: return .extraExtraLarge
        }
    }
    
    var uiFontPoint: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 17
        case .large: return 22
        }
    }
}
