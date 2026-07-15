//
//  TabRouter.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 1.07.2026.
//

import Foundation

enum Tab: Hashable {
    case notes, folders, settings
}

@Observable
final class TabRouter {
    var selectedTab: Tab = .notes
    private(set) var notesRouter: NotesRouter = .init()
    private(set) var foldersRouter: FoldersRouter = .init()
}
