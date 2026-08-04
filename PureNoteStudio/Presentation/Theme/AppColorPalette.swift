//
//  AppColorPalette.swift
//  PureNoteStudio
//

import SwiftUI

extension Color {
    /// Main screen background. Adapts to the active light or dark appearance.
    static let appPageBackground = Color(uiColor: .systemGroupedBackground)

    /// Raised content surface such as lists, forms, and alerts.
    static let appSurface = Color(uiColor: .secondarySystemGroupedBackground)

    /// Subtle interactive background for chips, search fields, and secondary actions.
    static let appControlBackground = Color(uiColor: .tertiarySystemFill)
}
