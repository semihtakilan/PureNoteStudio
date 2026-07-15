//
//  FoldersRoute.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 14.07.2026.
//

import SwiftUI

enum FoldersRoute: Hashable {
    case detail(Category)
}

enum FoldersSheet: Identifiable {
    case addCategory
    
    var id: String {
        switch self {
        case .addCategory:
            return "Add Category"
        }
    }
}

@Observable
final class FoldersRouter {
    var path = NavigationPath()
    var presentedSheet: FoldersSheet?
    
    func push(_ route: FoldersRoute) {
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
