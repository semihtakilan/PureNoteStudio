//
//  NotesRoute.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 1.07.2026.
//

import SwiftUI

enum NotesRoute: Hashable {
    case detail(Note)
    case sheets
}

@Observable
final class NotesRouter {
    var path = NavigationPath()
    
    func push(_ route: NotesRoute) {
        path.append(route)
    }

    func pop() {
        if path.isEmpty { return }
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}
